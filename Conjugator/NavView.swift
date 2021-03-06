//
//  NavView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

//Subjonctif Present ecrite

import SwiftUI
import Combine
import AVFoundation
import StoreKit

//let showIAPError = PassthroughSubject<String, Never>()
let showIAPMessage = PassthroughSubject<String, Never>()
let purchasePublisher = PassthroughSubject<(String, Bool), Never>()

enum MyAppPage {
  case menu
  case secondPage
  case navigationView
  case playerPage
  case listView
}

final class MyAppEnvironmentData: ObservableObject {
  @Published var currentPage: MyAppPage? = .menu
  @Published var level: String = "model"
  @Published var verby = VerbDB()
  @Published var tensey = TenseDB()
  @Published var answery = AnswerDB()
  @Published var bisy = BisDB()
//  @Published var groupy = groupDB()
  @Published var switchLanguage: Bool = false
}

var prime = true
var played = false

struct NavigationTest: View {
  var body: some View {
    NavigationView {
      ContentView()
    }
    .statusBar(hidden: true)
  }
}

var argent: String = ""

struct XContentView: View {
  @EnvironmentObject var env: MyAppEnvironmentData
  @State private var showingAlert = false
  
#if targetEnvironment(simulator)
  // your simulator code
  @State var purchased = true
#else
  @State var purchased = true
#endif

  var body: some View {
    WaitingV().onAppear {
      downLoadTenses(environment: self.env)
      downLoadConjugations(env: self.env)
    }
  }
}

struct ContentView: View {
  @EnvironmentObject var env: MyAppEnvironmentData
  @State private var showingAlert = false

#if targetEnvironment(simulator)
  // your simulator code
  @State var purchased = true
#else
  @State var purchased = true
#endif

  var body: some View {

    VStack {
      Text(env.switchLanguage ? "Conjugator":"Conjugueur")
        .font(Fonts.avenirNextCondensedBold(size: 32))
        .padding()
//        .modifier(DownLoadConjugations())
        .onAppear {
          downLoadTenses(environment: self.env)
          downLoadConjugations(env: self.env)
        }.onReceive(purchasePublisher) { ( toutBon ) in
          let (message, success) = toutBon
          if success {
            self.purchased = success
            showIAPMessage.send(message)
          }
        }
        
      NavigationLink(destination: PageTwo(), tag: .secondPage, selection: self.$env.currentPage) {
        EmptyView()
      }.navigationBarHidden(true)
      .statusBar(hidden: true)

      NavigationLink(destination: PlayerPage(), tag: .playerPage, selection: self.$env.currentPage) {
        EmptyView()
      }.navigationBarHidden(true)
      .statusBar(hidden: true)
      
      NavigationLink(destination: ListView(), tag: .listView, selection: self.$env.currentPage) {
        EmptyView()
      }.navigationBarHidden(true)
      .statusBar(hidden: true)
      
      Button(env.switchLanguage ? "Video":"Video") {
          self.env.currentPage = played ? .secondPage : .playerPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 50, trailing: 10))
        .onReceive(nextFrame) { (_) in
          played = true
        }

      if !purchased {
        BuyView(purchased: self.$purchased)
      } else {
        PaidView()
      }

        Spacer()
        HStack {
        Spacer()
          Text(env.switchLanguage ? "French":"Français")
            .font(Fonts.avenirNextCondensedBold(size: 10))
          Toggle("French", isOn: $env.switchLanguage)
            .font(Fonts.avenirNextCondensedBold(size: 10))
            .labelsHidden()
          Text(env.switchLanguage ? "English":"Anglais")
            .font(Fonts.avenirNextCondensedBold(size: 10))
        Spacer()
      }.padding()

    }
    .statusBar(hidden: true)
  }
}

struct PaidView: View {
  @EnvironmentObject var env: MyAppEnvironmentData

  var body: some View {
    
    VStack {
     Button(env.switchLanguage ? "Beginner":"Débutant") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["easy"], environment: self.env)
          self.env.currentPage = .secondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.gray.opacity(0.3))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
       
        Button(env.switchLanguage ? "Intermediate":"Intermédiaire") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["medium"], environment: self.env)
          self.env.currentPage = .secondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.gray.opacity(0.3))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        
        Button(env.switchLanguage ? "Advanced": "Avancé") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["hard"], environment: self.env)
          self.env.currentPage = .secondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.gray.opacity(0.3))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 50, trailing: 10))
        
        Button(env.switchLanguage ? "All Model Verbs":"Tous les verbes modèles") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["easy", "medium", "hard", "model"], environment: self.env)
          self.env.currentPage = .listView
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        
        Button(env.switchLanguage ? "More Verbs":"Tous les verbes") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["easy", "medium", "hard", "dynamic", "model"], environment: self.env)
          self.env.currentPage = .secondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        

        
      }
  }
}

struct BuyViewV5: View {
  @Binding var purchased: Bool
  @ObservedObject var products = ProductsDB.shared
  var body: some View {
      List {
        ForEach((0 ..< self.products.items.count), id: \.self) { column in
          Text(self.products.items[column].localizedDescription)
            .onTapGesture {
              let _ = IAPManager.shared.purchaseV5(product: self.products.items[column])
            }
        }
      }
  }
}

struct ContentViewV: View {
  @State var showingAlert = false
  @State var message = ""
  var body: some View {
   VStack {
     Text("Hello World")
       .onReceive(purchasePublisher) { ( toutBon ) in
             let (message, success) = toutBon
             if success {
               self.message = message
               self.showingAlert = true
             }
         }
            .alert(isPresented: $showingAlert) {
Alert(title: Text(message), message: Text(message), dismissButton: .default(Text("OK")))
          }
       }
    }
 }

struct BuyView: View {
  @EnvironmentObject var env: MyAppEnvironmentData
  @State private var message: String = ""
  @State private var showingAlert = false
  @Binding var purchased: Bool
  @ObservedObject var products = ProductsDB.shared
  @State var ready = false
  
  var body: some View {
    VStack {
      Button(env.switchLanguage ? "Buy": "Acheter") {
        print("products ", self.products)
        if !self.purchased {
          let success = IAPManager.shared.purchaseV5(product: self.products.items.filter({ "ch.cqd.moreVerbs" == $0.productIdentifier }).first!)
        }
      }
      .font(Fonts.avenirNextCondensedBold(size: 20))
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      .onReceive(showIAPMessage, perform: { ( message ) in
        self.message = message
        self.showingAlert = true
      })
      .alert(isPresented: $showingAlert) {
        Alert(title: Text(message), message: Text(message), dismissButton: .default(Text("OK")))
      }
      Button(env.switchLanguage ? "Restore": "Restaurer") {
        IAPManager.shared.restorePurchasesV5()
      }
      .font(Fonts.avenirNextCondensedBold(size: 20))
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      
      Button(env.switchLanguage ? "Beginner":"Débutant") {
          downLoadTenses(environment: self.env)
          downLoadVerbs(levels: ["easy"], environment: self.env)
          self.env.currentPage = .secondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        
    }
  }
}

struct WaitingV: View {
    
    let timer = Timer.publish(every: 1.6, on: .main, in: .common).autoconnect()
    @State var leftOffset: CGFloat = -100
    @State var rightOffset: CGFloat = 100
    
  var body: some View {
    ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(x: leftOffset)
                .opacity(0.7)
                .animation(Animation.easeInOut(duration: 1))
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(x: leftOffset)
                .opacity(0.7)
                .animation(Animation.easeInOut(duration: 1).delay(0.2))
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(x: leftOffset)
                .opacity(0.7)
                .animation(Animation.easeInOut(duration: 1).delay(0.4))
        }
        .onReceive(timer) { (_) in
            swap(&self.leftOffset, &self.rightOffset)
        }
  }
}

func downLoadTenses(environment: MyAppEnvironmentData) {
  if !environment.tensey.tensex.isEmpty {
    return
  }
  print("DownLoadTenses")
  let tenses = [
    "1-1.Indicatif présent.Dérivé du radical de l'infinitif présent.1.Present Indicative.Derived from infinitive stem.5",
    "2-2.Indicatif futur simple.Dérivé de l'infinitif complet.1.Future Indicative.Derived from full infinitive.5",
    "3-3.Indicatif imparfait.Dérivé du radical du nous de l’indicatif présent.1.Imperfect Indicative.Derived from the stem of nous indicative present.4",
    "4-4.Indicatif passé simple.Dérivé du radical du nous de l’indicatif présent.1.Simple past indicative.Derived from the stem of the present nous.4",
    "5-5.Subjonctif présent.Dérivé du radical du Ils de l’indicatif présent.1.Present Subjunctive.Derived from the stem of Ils indicative present.4",
    "6-6.Subjonctif imparfait.Dérivé du radical unique du passé simple.1.Imperfect Subjunctive.Derived from the unique simple past stem.3",
    "7-7.Conditionnel présent.Dérivé de l'infinitif complet.1.Present Conditional.Derived from the full infinitive.5",
    "9-9.Participe présent.Dérivé du radical du nous de l’indicatif présent.1.Present Participle.Derived from the stem of nous indicative present.5",
    "10-9.Participe passé.Dérivé du radical de l'infinitif présent.1.Past Participle.The past participle from the infinitive stem.5",
    "20-10.Infinitif présent.Forme de base.0.Present Infinitive.Basic form.5"]
    
    // Last number in above links to this order, not the order in red
    // 0 Conditional Present
    // 1 Indicatif future simple
    // 2 Indicative imparfait
    // 3 Indicative passe simple
    // 4 Indicative present
    // 5 Infinitive present complete
    // 6 Particple Passe
    // 7 Participle Passe
    // 8 Subjective Imparfait
    // 9 Subjective Present
  
  for instance in tenses {
  
    let bo = instance.split(separator: ".")
    let bd = bo[0].split(separator: "-")
//    let newTense = TenseBlob(id: Int(breakdown[0]),
// groupID: Int(breakdown[1]), name: String(breakout[1]), derive: String(breakout[2]), color: String(breakout[3])
//,nom: String(breakout[4]), worked: String(breakout[5]),linked: Int(breakout[6]))
    let newTense = TenseBlob(id: bd[0].c2Int(), groupID: bo[1].c2Int(), name: bo[1].c2Str(), derive: bo[2].c2Str(), color: bo[3].c2Str(),nom: bo[4].c2Str(), worked: bo[5].c2Str(),linked: bo[6].c2Int())
    environment.tensey.tensex.append(newTense)
    
  }
  
  environment.tensey.tensex.sort { (first, second) -> Bool in
    first.name < second.name
  }
}

func downLoadVerbs(levels: [String], environment: MyAppEnvironmentData) {
  
  environment.verby.verbx.removeAll()
  print("downloading ... ", environment.level)
  
    let content = readVerb(fileName: "verb")
    
    for lines in content! {
      if lines.count > 1 {
        for level in levels {
          let verb = lines.split(separator: ",")
          let index = Int(String(verb[0]))
          let link = Int(String(verb[2]))
          let stage = String(verb[3])
          if level == stage {
            let newVerb = VerbBlob(id: index, name: String(verb[1]), link: link)
            environment.verby.verbx.append(newVerb)
          }
      }
    }
  }
  let french = Locale(identifier: "fr-CH")
  environment.verby.verbx.sort { (first, second) -> Bool in
    (first.name!.compare(second.name!, locale: french)) == .orderedAscending
  }
}

func downLoadConjugations(env: MyAppEnvironmentData) {
       if prime {
          prime = false
        env.tensey.tensex.removeAll()
        env.answery.answerx.removeAll()
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
            let tense = lines.split(separator: ",")
            let verbID = Int(String(tense[0]).trimmingCharacters(in: .whitespacesAndNewlines))
            let tenseID = Int(String(tense[1]).trimmingCharacters(in: .whitespacesAndNewlines))
            var conjugation: String!
            if tense[4].trimmingCharacters(in: .whitespacesAndNewlines) != "0" {
              conjugation = String(tense[3].trimmingCharacters(in: .whitespacesAndNewlines) + " " + tense[4].trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
              conjugation = String(tense[3].trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let personID = returnClass(class2C: String(tense[3]).trimmingCharacters(in: .whitespacesAndNewlines))

            var redMask: Int!
            if tense.count > 5 {
              redMask = Int(String(tense[5]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 6 {
              redMask = Int(String(tense[6]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 7 {
              redMask = Int(String(tense[7]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 8 {
              redMask = Int(String(tense[8]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 9 {
              redMask = Int(String(tense[9]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if redMask == nil {
              redMask = 0
            }
            
            print("red ", tense[0], redMask!)
            
            if verbID != nil {
              let newAnswer = AnswerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              env.answery.answerx.append(newAnswer)
            }
          }
        }
    }
}

struct DownLoadConjugations: ViewModifier {
  @EnvironmentObject var env: MyAppEnvironmentData
  func body(content: Content) -> some View {
    content
      .onAppear {
        if prime {
          prime = false
        self.env.tensey.tensex.removeAll()
        self.env.answery.answerx.removeAll()
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
            let tense = lines.split(separator: ",")
            let verbID = Int(String(tense[0]).trimmingCharacters(in: .whitespacesAndNewlines))
            let tenseID = Int(String(tense[1]).trimmingCharacters(in: .whitespacesAndNewlines))
            var conjugation: String!
            if tense[4].trimmingCharacters(in: .whitespacesAndNewlines) != "0" {
              conjugation = String(tense[3].trimmingCharacters(in: .whitespacesAndNewlines) + " " + tense[4].trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
              conjugation = String(tense[3].trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let personID = returnClass(class2C: String(tense[2]).trimmingCharacters(in: .whitespacesAndNewlines))

            var redMask: Int!
            if tense.count > 5 {
              redMask = Int(String(tense[5]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 6 {
              redMask = Int(String(tense[6]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 7 {
              redMask = Int(String(tense[7]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 8 {
              redMask = Int(String(tense[8]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if tense.count > 9 {
              redMask = Int(String(tense[9]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if redMask == nil {
              redMask = 0
            }
            
            print("red ", tense[0], redMask!)
            
            if verbID != nil {
              let newAnswer = AnswerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              self.env.answery.answerx.append(newAnswer)
            }
          }
        }
    }
  }
 
  }
}

func returnClass(class2C: String) -> PersonClass {
   var personID: PersonClass!
            switch class2C {
            case "Je":
              personID = PersonClass.a1
            case "J'":
              personID = PersonClass.a1
            case "J’":
              personID = PersonClass.a1
            case "Tu":
              personID = PersonClass.a2
            case "Il":
              personID = PersonClass.a3
            case "Nous":
              personID = PersonClass.b1
            case "Vous":
              personID = PersonClass.b2
            case "Ils":
              personID = PersonClass.a4
            default:
              personID = PersonClass.cx
            }
            print("personID ",personID)
    return personID
}

extension Substring {
  func c2Int() -> Int {
    return Int(String(self)) ?? 0
  }
}

extension Substring {
  func c2Str() -> String {
    return String(self)
  }
}

//#if DEBUG
//struct NavigationTest_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationTest().environmentObject(MyAppEnvironmentData())
//  }
//}
//#endif
