//
//  ContentView.swift
//  Conjugator
//
//  Created by localadmin on 20.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine
import AVKit

let populatePublisher = PassthroughSubject<String?,Never>()
let rulesPublisher = PassthroughSubject<Void,Never>()
let doDivertPublisher = PassthroughSubject<Int,Never>()
let defaultLinkColor = PassthroughSubject<Void,Never>()

var shaker = true
var once = true

enum PersonClass {
  case a1
  case a2
  case a3
  case b1
  case b2
  case a4
  case cx
}

struct verbBlob {
  var id:Int!
  var name:String!
  var link:Int?
}

final class verbDB: ObservableObject, Identifiable {
  @Published var verbx:[verbBlob] = [] {
    willSet {
      objectWillChange.send()
    }
  }
}

func readVerb(fileName:String) -> [String]? {
  let fileURL = Bundle.main.url(forResource:fileName, withExtension: "txt")
  do {
    if try fileURL!.checkResourceIsReachable() {
      
      let data = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
      
      let myStrings = data.components(separatedBy: .newlines)
      return myStrings
      
    } else {
      print("file doesnt exist")
    }
  } catch {
    print("an error happened while checking for the file")
  }
  return nil
}

func readConjugations() -> [String]? {
  let fileURL = Bundle.main.url(forResource:"conjugationsFull", withExtension: "txt")
  do {
    if try fileURL!.checkResourceIsReachable() {
      print("file exist")
      let data = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
      //           let myStrings = data.components(separatedBy: .controlCharacters)
      let myStrings = data.components(separatedBy: .newlines)
      return myStrings
    } else {
      print("file doesnt exist")
    }
  } catch {
    print("an error happened while checking for the file")
  }
  return nil
}

struct tenseBlob {
  var id:Int!
  var groupID:Int!
  var name:String!
  var derive:String!
  var color:String!
  var nom:String!
  var worked:String!
}

final class tenseDB: ObservableObject, Identifiable {
  @Published var tensex:[tenseBlob] = [] {
    willSet {
      objectWillChange.send()
    }
  }
}

struct answerBlob {
  var verbID: Int!
  var tenseID: Int!
  var personID: PersonClass!
  var name:String!
  var redMask:Int?
  var stemMask:Int?
  var termMask:Int?
}

final class answerDB: ObservableObject, Identifiable {
  @Published var answerx:[answerBlob] = [] {
    willSet {
      objectWillChange.send()
    }
  }
}

struct groupBlob {
  var groupID: Int!
  var name:String!
}

final class groupDB: ObservableObject, Identifiable {
  @Published var groupx:[groupBlob] = [] {
    willSet {
      objectWillChange.send()
    }
  }
}

struct Fonts {
  static func avenirNextCondensedBold (size:CGFloat) -> Font{
    return Font.custom("AvenirNextCondensed-Bold",size: size)
  }
  
  static func avenirNextCondensedMedium (size:CGFloat) -> Font{
    return Font.custom("AvenirNextCondensed-Medium",size: size)
  }
}

struct newView: View {
  
  @EnvironmentObject var env : MyAppEnvironmentData
  @State var word:String
  @State var gate:Int?
  @Binding var selections:[answerBlob]
  @Binding var display2Conjugations:Bool
  @State var color2U:Color!
  
  var body: some View {
    let letter = word.map( { String($0) } )
    
    return VStack {
      HStack(spacing:0) {
        ForEach((0 ..< letter.count), id: \.self) { column in
          Text(letter[column])
            .foregroundColor(colorCode(gate: Int(self.gate!), no: column) ? Color.red: self.color2U)
        }
      }.onTapGesture() {
        if linkID != nil {
          if linkID != 0  {
            self.selections.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
              for instance in self.env.answery.answerx {
                if instance.tenseID == tenseID && instance.verbID == linkID {
                  self.selections.append(instance)
                }
              }
              self.selections.sort { (first, second) -> Bool in
                first.personID.debugDescription < second.personID.debugDescription
              }
              doDivertPublisher.send(linkID)
              defaultLinkColor.send()
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
                self.display2Conjugations = true
              }
            }
          }
        }
      }
    }
  }
}



//struct ListView: View {
//  @Binding var name:String
//  @State var device: String
//  @State var isSelected: Bool
//
//  var body: some View {
//    Text(device)
//      .listRowBackground(self.isSelected ? Color.yellow: Color.clear)
//      .onTapGesture {
//        self.name = self.device
//        self.isSelected = !self.isSelected
//    }
//  }
//}
//
//struct TextView: View {
//  @State var textValue:String!
//  @State var textOK = true
//  var body: some View {
//    if textValue.isEmpty {
//      textOK = false
//    }
//    var twoText = textValue.split(separator: " ")
//    if twoText.count == 1 {
//      twoText.append(" ")
//    }
//    return HStack {
//      Text(textOK ? twoText[0] : "")
//      Text(textOK ? twoText[1] : "")
//    }
//  }
//}

let bsize:CGFloat = 48
let asize:CGFloat = 32
let fsize:CGFloat = 32
let qsize:CGFloat = 20

var ruleColors:[Color] = [Color.blue, Color.purple, Color.green, Color.red, Color(red:255/255, green:105/255, blue:180/255), Color.orange, Color.clear, Color.yellow]
//var verbs: [Int:String] = [7:"Parler",2:"Avoir",70:"Finir",77:"Prendre",81:"Savoir"]


var rien = [String](repeating: " ", count: 7)
var linkID: Int!

var verbID: Int!
var tenseID: Int!
var personID: PersonClass!

struct PageTwo: View {
  
  @State private var newValue: CGFloat = 256
  @State private var showMe = [Bool](repeating: false, count: 6)
  @EnvironmentObject var env : MyAppEnvironmentData
  
  //Indicatif présent	dérivé du radical de l’infinitif
  //Indicatif futur	dérivé de l’infinitif complet
  //Indicatif imparfait	dérivé du radical nous du présent
  //Indicatif passé simple	dérivé du radical nous du présent
  
  //Subjonctif présent	dérivé du radical du ils du présent
  //Subjonctif imparfait	dérivé du radical du passé simple
  
  //Conditionnel présent	dérivé de l’infinitif complet
  //Participe passé	dérivé du radical de l’infinitif
  //Participe présent	dérivé du radical du nous du présent
  //Infinitif présent	forme de base
  
  // finir/parle easy
  // avoir/savoir advanced
  // prendre advanced
  
  @State var tenses = [
    "1-1.Indicatif présent.Dérivé du radical de l'infinitif.1.Present indicative.Derived from infinitive stem",
    "2-2.Indicatif futur.Dérivé de l'infinitif complet.1.Future indicative.Derived from full infinitive",
    "3-3.Indicatif imparfait.Dérivé du radical du nous du présent.1.Imperfect indicative.Derived from the stem of nous present",
    "4-4.Indicatif passé simple.Dérivé du radical du nous du présent.1.Past participle.Derived from infinitive stem",
    "5-5.Subjonctif Présent.Dérivé du radical du ils du présent.1.Present subjunctive.Derived from the stem of ils present",
    "6-6.Subjonctif Imparfait.Dérivé du radical du passé simple.1.Imperfect subjunctive.Derived from the simple past stem",
    "7-7.Conditionnel Présent.Dérivé de l'infinitif complet.1.Present conditional.Derived from the full infinitive",
    "9-8.Participe Présent.Dérivé du radical du nous du présent.1.Present participle.Derived from the stem of nous present",
    "10-9.Participe Passé.Dérivé du radical de l'infinitif.1.Simple past indicative.Derived from the stem of nous present",
    "20-10.Infinitif Présent.Forme de base.0.Present infinitive.Basic form"]
  @State var temps = [
    "1-1.Future indicative.Derived from the full infinitive",
    "2-2.Imperfect indicative.Derived from the stem of the nous present",
    "3-3.Imperfect subjunctive.Derived from the simple past stem",
    "4-4.Past participle.Derived from the infinitive stem",
    "5-5.Present conditional.Derived from the full infinitive",
    "6-6.Present indicative.Derived from the infinitive stem",
    "7-7.Present infinitive.Basic form",
    "9-8.Present participle.Derived from the stem of the nous present",
    "10-9.Present subjunctive.Derived from the stem of the ils present",
    "20-10.Simple past indicative.Derived from the stem of the nous present",
  ]
  
  @State var verb:[String] = []
  @State var selectedVerb = 0
  @State var selectedGroup = 0
  @State var linkColor: Color = Color.red
  
  @State var groupName = ""
  @State var groupColor = true
  
  @State var selectedTense = 9
  @State var verbSelected = ""
  @State var preVerbSelected = ""
  @State var postVerbSelected = ""
  @State var tenseSelected = ""
  @State var preTenseSelected = ""
  @State var postTenseSelected = ""
  
  //  @State var answer = [String](repeating: "", count: 7)
  @State var colors = [Int](repeating: 0, count: 7)
  @State var selectedAnswer = 0
  
  @State var blanks = [String](repeating: "", count: 7)
  @State var display0Verb = false
  @State var display0Tense = false
  @State var display2Conjugations = false
  @State var display0Conjugations = false
  
  @State var display1Verb = true
  @State var display1Tense = true
  
  @State var showColor = false
  //  @State var verbID:Int!
  //  @State var verbLink:Int!
  //  @State var tenseID:Int!
  //  @State var personID: PersonClass!
  @State var utiliser:String!
  
  @State var lvalue:Int = 99
  @State var pvalue:Int = 99
  
  @State var isSelect1S = false
  @State var isSelect2S = false
  @State var isSelect3S = false
  @State var isSelect1P = false
  @State var isSelect2P = false
  @State var isSelect3P = false
  
  @State var answerText:String = ""
  @State var ruleColor: Color = Color.clear
  
  @State var hintOne:String = ""
  @State var hintTwo:String = ""
  @State var hintOneVisible = false
  @State var hintTwoVisible = false
  
  @State var noDivert = true
  
  @State var selections:[answerBlob] = []
  @State private var action: Int? = 0
  @State private var overText = false
  
  var body: some View {
    
    func resetButtons() {
      self.isSelect1P = false
      self.isSelect2P = false
      self.isSelect3P = false
      self.isSelect1S = false
      self.isSelect2S = false
      self.isSelect3S = false
    }
    
    func findIndex() -> Int? {
      //      let bob = answery.answerx.filter({ verbID == $0.verbID && tenseID == $0.tenseID && personID == $0.personID})
      let zak = env.answery.answerx.firstIndex { ( data ) -> Bool in
        data.personID == personID && data.verbID == verbID && data.tenseID == tenseID
      }
      return zak
    }
    
    func findVerbIndex(searchID: Int) -> Int {
      let zak = env.verby.verbx.firstIndex { (data ) -> Bool in
        data.id == searchID
      }
      return zak!
    }
    
    func findVerb(searchID: Int) -> String {
      let bob = env.verby.verbx.filter({ searchID == $0.id })
      return (bob.first?.name)!
    }
    
    func findAnswer() -> String? {
      let bob = env.answery.answerx.filter({ verbID == $0.verbID && tenseID == $0.tenseID && personID == $0.personID})
      print("answer [\(bob)]")
      if bob.isEmpty {
        return("")
      } else {
        return bob.first?.name!
      }
    }
    
//    func findHint1() -> String? {
//      let bob = env.tensey.tensex.filter({ tenseID == $0.id })
////      let sue = env.groupy.groupx.filter({ bob.first?.groupID == $0.groupID})
//      if bob.isEmpty {
//        return("")
//      } else {
//        return sue.first?.name!
//      }
//    }
    
    
    //    let navlink2 = NavigationLink(destination: AdminView(),
    //                       tag: .NavigationView,
    //                       selection: $env.currentPage,
    //                       label: { EmptyView() })
    
    let design = UIFontDescriptor.SystemDesign.rounded
    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
      .withDesign(design)!
    let font = UIFont.init(descriptor: descriptor, size: 48)
    UINavigationBar.appearance().largeTitleTextAttributes = [.font : font]
    
    return VStack(alignment: .center) {
      // Tried using $env.currentPage, but it seemed to be too slow setting this up
      NavigationLink(destination: AdminView(), tag: 1, selection: $action) {
        EmptyView()
      }
      
//       Text(env.switchLanguage ? "Conjugator":"Conjugateur")
       
      Text("fooBar").frame(width: 256, height: 0, alignment: .center)
        .navigationBarTitle(Text(env.switchLanguage ? "Conjugator":"Conjugateur"), displayMode: .inline).font(Fonts.avenirNextCondensedBold(size: 20))
        .navigationBarItems(trailing: Text("Admin").onTapGesture {
          self.action = 1
          self.env.currentPage = .NavigationView
        })
        .opacity(0)
        .onAppear {
          populatePublisher.send(nil)
        }.onReceive(defaultLinkColor) { (_) in
          self.linkColor = Color.black
        }
      
      ZStack {
        if display0Verb {
          Picker("", selection: $selectedVerb) {
            ForEach((0 ..< env.verby.verbx.count), id: \.self) { column in
              Text(self.display0Verb ? self.env.verby.verbx[column].name : "")
                .font(Fonts.avenirNextCondensedBold(size: 24))
                
            }
          }
          .frame(width: 256, height: 162, alignment: .center)
//          .background(InsideView)
          .offset(x: 0, y: -32)
          .onReceive([selectedVerb].publisher.first()) { ( value ) in
            self.selectedVerb = value
          }
          .onTapGesture() {
            self.selections.removeAll()
            self.display2Conjugations = false
            
            verbID = self.env.verby.verbx[self.selectedVerb].id
            linkID = self.env.verby.verbx[self.selectedVerb].link
            
            print("bug alert ",self.selectedVerb,linkID)
            
            if linkID != 0 {
              self.utiliser = "Même règle que " + findVerb(searchID: linkID)
              self.linkColor = Color.blue
            } else {
              self.linkColor = Color.black
            }
            
            self.display0Tense = false
            self.display1Tense = true
            self.display2Conjugations = false
            self.preVerbSelected = self.selectedVerb > 0 ? self.env.verby.verbx[self.selectedVerb - 1].name : ""
            self.postVerbSelected = self.selectedVerb < (self.env.verby.verbx.count - 1 ) ? self.env.verby.verbx[self.selectedVerb + 1].name : ""
            self.verbSelected = self.env.verby.verbx[self.selectedVerb].name
            
            //              if self.selectedVerb != self.pvalue {
            self.display2Conjugations = true
            //                self.display2Conjugations = false
            self.selections.removeAll()
            if linkID! == 0 {
              for instance in self.env.answery.answerx {
                if instance.tenseID == tenseID && instance.verbID == verbID {
                  self.selections.append(instance)
                }
              }
              self.selections.sort { (first, second) -> Bool in
                first.personID.debugDescription < second.personID.debugDescription
              }
            } else {
              if self.noDivert {
                let spc = answerBlob(verbID: verbID, tenseID: tenseID, personID: PersonClass.cx, name: self.utiliser, redMask: 0, stemMask: nil, termMask: nil)
                self.selections.append(spc)
              }
            }
            
            //                self.pvalue = self.selectedVerb
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
              self.display2Conjugations = true
              self.display0Tense = true
              self.display1Tense = false
              self.display0Verb = false
              self.display1Verb = true
              self.display2Conjugations = true
              self.newValue = 256
              for i in 0...5 {
                self.showMe[i] = false
              }
            }
            //              }
          }
          .labelsHidden()
          .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        } else {
          if display1Verb {
            VerbView(display0Verb: $display0Verb, display1Verb: $display1Verb, preVerbSelected: $preVerbSelected, verbSelected: $verbSelected, postVerbSelected: $postVerbSelected)
              .frame(width: 256, height: 162, alignment: .center)
              .offset(x: 0, y: -32)
              .onReceive(doDivertPublisher, perform: { ( row ) in
                
                
                self.display1Verb = false
                self.display0Verb = true
                self.noDivert = false
                print("verb ",findVerbIndex(searchID: row))
                self.selectedVerb = findVerbIndex(searchID: row)
                verbID = self.env.verby.verbx[self.selectedVerb].id
                linkID = self.env.verby.verbx[self.selectedVerb].link
                
                self.preVerbSelected = self.selectedVerb > 0 ? self.env.verby.verbx[self.selectedVerb - 1].name : ""
                self.postVerbSelected = self.selectedVerb < (self.env.verby.verbx.count - 1 ) ? self.env.verby.verbx[self.selectedVerb + 1].name : ""
                self.verbSelected = self.env.verby.verbx[self.selectedVerb].name
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                  self.display1Verb = true
                  self.display0Verb = false
                  self.noDivert = true
                }
              })
          }
        }
      }
      
      
      ZStack {
        if display0Tense {
          Picker("", selection: $selectedTense) {
            ForEach((0 ..< self.env.tensey.tensex.count), id: \.self) { column in
              //        ForEach(0 ..< tenses.count) {
              Text(self.env.switchLanguage ? self.env.tensey.tensex[column].nom: self.env.tensey.tensex[column].name)
                .font(Fonts.avenirNextCondensedBold(size: 24))
                .background(self.showColor ? Color.yellow: Color.clear)
            }
          }.labelsHidden()
            .frame(width: 256, height: 162, alignment: .center)
            .offset(x: 0, y: -64)
            .onReceive([selectedTense].publisher) { ( value ) in
              self.selectedTense = value
          }
          .onTapGesture() {
            self.selections.removeAll()
            self.display2Conjugations = false
            
            self.display1Verb = true
            
            tenseID = self.env.tensey.tensex[self.selectedTense].id
            self.groupName =  self.env.switchLanguage ? self.env.tensey.tensex[self.selectedTense].worked : self.env.tensey.tensex[self.selectedTense].derive
            self.groupColor = self.env.tensey.tensex[self.selectedTense].color == "1" ? true:false
            
            if self.selectedTense > 0 {
              self.preTenseSelected =  self.env.switchLanguage ? self.env.tensey.tensex[self.selectedTense - 1].nom : self.env.tensey.tensex[self.selectedTense - 1].name
            } else {
              self.preTenseSelected = ""
            }
            
//            self.preTenseSelected = self.selectedTense > 0 ? self.env.tensey.tensex[self.selectedTense - 1].name : ""

            if self.selectedTense < (self.env.tensey.tensex.count - 1 ) {
              self.postTenseSelected = self.env.switchLanguage ? self.env.tensey.tensex[self.selectedTense - 1].nom : self.env.tensey.tensex[self.selectedTense + 1].name
            } else {
              self.postTenseSelected = ""
            }
//            self.postTenseSelected = self.selectedTense < (self.env.tensey.tensex.count - 1 ) ? self.env.tensey.tensex[self.selectedTense + 1].name : ""
            self.tenseSelected = self.env.switchLanguage ? self.env.tensey.tensex[self.selectedTense].nom : self.env.tensey.tensex[self.selectedTense].name
            
            if linkID != 0 {
              self.utiliser = "Même règle que " + findVerb(searchID: linkID)
              self.linkColor = Color.blue
            } else {
              self.linkColor = Color.black
            }
            self.display2Conjugations = false
            self.selections.removeAll()
            if linkID! == 0 {
              for instance in self.env.answery.answerx {
                if instance.tenseID == tenseID && instance.verbID == verbID {
                  self.selections.append(instance)
                }
              }
              self.selections.sort { (first, second) -> Bool in
                first.personID.debugDescription < second.personID.debugDescription
              }
            } else {
              if self.noDivert {
                let spc = answerBlob(verbID: verbID, tenseID: tenseID, personID: PersonClass.cx, name: self.utiliser, redMask: 0, stemMask: nil, termMask: nil)
                self.selections.append(spc)
              }
            }
            if !self.groupColor {
              self.selections.removeAll()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
              self.display0Tense = false
              self.display1Tense = true
              self.display0Verb = false
              self.display1Verb = true
              self.newValue = 256
              for i in 0...5 {
                self.showMe[i] = false
              }
              withAnimation { ()
                self.display2Conjugations = true
              }
              
            }
            //            }
          }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
        if display1Tense {
          TenseView(display0Tense: $display0Tense, display1Tense: $display1Tense, preTenseSelected: $preTenseSelected, tenseSelected: $tenseSelected, postTenseSelected: $postTenseSelected)
            .frame(width: 256, height: 162, alignment: .center)
            .offset(x: 0, y: -64)
        }
        
      } // ZStack
      Text(groupName)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .background(groupColor ? Color.yellow: Color.clear)
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .offset(x: 0, y: -64)
      if display2Conjugations {
        List {
          ForEach((0 ..< self.selections.count), id: \.self) { column in
            HStack(spacing:0) {
              Spacer()
             newView(env: self._env, word: self.selections[column].name, gate: self.selections[column].redMask!, selections: self.$selections, display2Conjugations: self.$display2Conjugations, color2U: self.linkColor)
//              Text(self.selections[column].name)
                .opacity(self.showMe[column] ? 1 : 0)
                //                  .offset(x: 0, y: self.newValue)
                .font(Fonts.avenirNextCondensedBold(size: 22))
                .onAppear(perform: {
            for i in 0..<6 {
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                withAnimation(.easeOut(duration: 8.0)) {
                  //                    self.newValue = 0
                  self.showMe[i] = true
                }
              }
            }
          })
              Spacer()
            }
          }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }.environment(\.defaultMinListRowHeight, 20)
          .environment(\.defaultMinListHeaderHeight, 0)
          .frame(width: UIScreen.main.bounds.size.width, height: 180.5, alignment: .center)
          .offset(x: 0, y: -64)
          
        //        .background(InsideView())
        
      } else {
        Spacer()
          .frame(width: UIScreen.main.bounds.size.width, height: 180.5, alignment: .center)
          .offset(x: 0, y: -64)
      }
      Spacer()
      
    }.statusBar(hidden: true) // VStack
    
      .onReceive(rulesPublisher, perform: { ( _ ) in
        self.display0Verb = false
        self.env.verby.verbx.removeAll()
        //      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
        //      for instance in groups {
        //        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        //        self.env.groupy.groupx.append(newGroup)
        //      }
      })
      .onReceive(populatePublisher, perform: { ( seek ) in
        self.display0Verb = false
        self.display0Tense = false
        self.display2Conjugations = false
        
        
        
        if once {
          once = false
          
          //      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
          //      for instance in dictSortByValue {
          //        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
          //        self.env.groupy.groupx.append(newGroup)
          //      }
          
          for instance in self.tenses {
            let breakout = instance.split(separator: ".")
            let breakdown = breakout[0].split(separator: "-")
            let newTense = tenseBlob(id: Int(breakdown[0]), groupID: Int(breakdown[1]), name: String(breakout[1]), derive: String(breakout[2]), color: String(breakout[3]),nom: String(breakout[4]), worked: String(breakout[5]))
            self.env.tensey.tensex.append(newTense)
          }
          
          self.env.tensey.tensex.sort { (first, second) -> Bool in
            first.name < second.name
          }
        }
        
        if seek != nil {
          self.selectedVerb = self.env.verby.verbx.firstIndex(where: { ( data ) -> Bool in
            seek == data.name
          })!
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(2)) {
          shaker = true
          self.display0Verb = true
          //        self.display0Tense = true
          self.display2Conjugations = true
        }
      }).statusBar(hidden: true)
    
    
  }
}



func colorCode(gate:Int, no:Int) -> Bool {
  
  let bgr = String(gate, radix:2).pad(with: "0", toLength: 16)
  let bcr = String(no, radix:2).pad(with: "0", toLength: 16)
  let binaryColumn = 1 << no
  
  let value = UInt64(gate) & UInt64(binaryColumn)
  let vr = String(value, radix:2).pad(with: "0", toLength: 16)
  
  //    print("bg ",bgr," bc ",bcr,vr)
  return value > 0 ? true:false
}

struct TenseView: View {
  @Binding var display0Tense:Bool
  @Binding var display1Tense:Bool
  @Binding var preTenseSelected:String
  @Binding var tenseSelected:String
  @Binding var postTenseSelected:String
  
  var body: some View {
    VStack {
      Text(preTenseSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Tense = false
          self.display0Tense = true
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0))
      Text(tenseSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Tense = false
          self.display0Tense = true
      }
      Text(postTenseSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Tense = false
          self.display0Tense = true
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(10), axis: (x: -1, y: 0, z: 0))
    }
  }
}



struct VerbView: View {
  @Binding var display0Verb:Bool
  @Binding var display1Verb:Bool
  @Binding var preVerbSelected:String
  @Binding var verbSelected:String
  @Binding var postVerbSelected:String
  
  var body: some View {
    VStack {
      Text(preVerbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Verb = false
          self.display0Verb = true
          //            self.display0Tense.toggle()
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0))
      Text(verbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Verb = false
          self.display0Verb = true
          //            self.display0Tense.toggle()
      }
      Text(postVerbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display1Verb = false
          self.display0Verb = true
          //            self.display0Tense.toggle()
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(10), axis: (x: -1, y: 0, z: 0))
    }
    
    
  }
}

struct InsideView: View {
  var body: some View {
    
    return VStack {
      GeometryReader { geometry in
        Rectangle()
          .fill(Color.green)
          .opacity(0.2)
          .onAppear {
            print("geo ",geometry.frame(in: .global))
        }
      }
      
    }
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    PageTwo()
  }
}



extension String {
  func pad(with character: String, toLength length: Int) -> String {
    let padCount = length - self.count
    guard padCount > 0 else { return self }
    
    return String(repeating: character, count: padCount) + self
  }
}

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}


