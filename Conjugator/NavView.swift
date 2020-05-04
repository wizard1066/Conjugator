//
//  NavView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation


enum MyAppPage {
  case Menu
  case SecondPage
  case NavigationView
  case PlayerPage
}

final class MyAppEnvironmentData: ObservableObject {
  @Published var currentPage : MyAppPage? = .Menu
  @Published var level:String = "model"
  @Published var verby = verbDB()
  @Published var tensey = tenseDB()
  @Published var answery = answerDB()
//  @Published var groupy = groupDB()
  @Published var switchLanguage:Bool = false
}

var prime = true

struct NavigationTest: View {
  var body: some View {
    NavigationView {
      ContentView()
    }
    .statusBar(hidden: true)
  }
}




struct ContentView: View {
  @EnvironmentObject var env : MyAppEnvironmentData
//  @State private var switchLanguage = false
  @State private var intro2Do = true
  
  var body: some View {

    VStack {
      Text(env.switchLanguage ? "Conjugator":"Conjugateur")
        .font(Fonts.avenirNextCondensedBold(size: 32))
        .padding()
        .modifier(DownLoadConjugations())
        
        
      NavigationLink(destination: PageTwo(), tag: .SecondPage, selection: self.$env.currentPage) {
        EmptyView()
      }.navigationBarHidden(true)
      .statusBar(hidden: true)


      NavigationLink(destination: playerPage(), tag: .PlayerPage, selection: self.$env.currentPage) {
        EmptyView()
      }.navigationBarHidden(true)
      .statusBar(hidden: true)
      
      
      Button(env.switchLanguage ? "Model Verbs":"Verbes Modèles") {
          DownLoadVerbs(levels:["model"], environment: self.env)
          self.intro2Do = false
          self.env.currentPage = prime ? .SecondPage : .PlayerPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))


      Button(env.switchLanguage ? "Beginner":"Débutant") {
          DownLoadVerbs(levels:["easy"], environment: self.env)
          self.env.currentPage = .SecondPage
        }

        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)

        Button(env.switchLanguage ? "Intermediate":"Intermédiaire") {
          DownLoadVerbs(levels:["medium"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)

        Button(env.switchLanguage ? "Advanced": "Avancé") {
          DownLoadVerbs(levels:["hard"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)

        Button(env.switchLanguage ? "Superior":"Supérieur") {
          DownLoadVerbs(levels:["easy","medium","hard","dynamic","model"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)

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

func DownLoadVerbs(levels:[String], environment: MyAppEnvironmentData) {
  
  environment.verby.verbx.removeAll()
  
  
  print("downloading ... ",environment.level)
  
    let content = readVerb(fileName: "verb")
    
    for lines in content! {
      if lines.count > 1 {
        for level in levels {
          let verb = lines.split(separator: ",")
          let index = Int(String(verb[0]))
          let link = Int(String(verb[2]))
          let stage = String(verb[3])
          if level == stage {
            let newVerb = verbBlob(id: index, name: String(verb[1]), link: link)
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

struct DownLoadConjugations: ViewModifier {
  @EnvironmentObject var env : MyAppEnvironmentData
  func body(content: Content) -> some View {
    content
      .onAppear {
        if prime {
          prime = false
        self.env.tensey.tensex.removeAll()
//        self.env.groupy.groupx.removeAll()
        self.env.answery.answerx.removeAll()
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
//            print("verb ",lines)
            
            let tense = lines.split(separator: ",")
            
            if lines.contains("abso") {
              print("tense ",tense)
            }
            
            let verbID = Int(String(tense[1]))
            let tenseID = Int(String(tense[2]))
            let conjugation = String(tense[5] + " " + tense[6])
            //            for instance in self.answers {
            let personID = returnClass(class2C: String(tense[5]))

            
            var redMask:Int!
            if tense.count > 9 {
              redMask = Int(tense[9])
            }
            if tense.count > 10 {
              redMask = Int(tense[9] + tense[10])
            }
            if tense.count > 11 {
              redMask = Int(tense[9] + tense[10] + tense[11])
            }
            if redMask == nil {
              redMask = 0
            }
            
            if verbID != nil {
              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              self.env.answery.answerx.append(newAnswer)
            }
          }
        }
    }
  }
 
  }
}

func returnClass(class2C:String) -> PersonClass {
   var personID:PersonClass!
            //        print("conjugation ",conjugation)
            switch class2C {
            case "Je":
              personID = PersonClass.a1
              break
            case "J'":
              personID = PersonClass.a1
              break
            case "Tu":
              personID = PersonClass.a2
              break
            case "Il":
              personID = PersonClass.a3
              break
            case "Nous":
              personID = PersonClass.b1
              break
            case "Vous":
              personID = PersonClass.b2
              break
            case "Ils":
              personID = PersonClass.a4
              break
            default:
              personID = PersonClass.cx
            }
    return personID
}



//#if DEBUG
//struct NavigationTest_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationTest().environmentObject(MyAppEnvironmentData())
//  }
//}
//#endif


