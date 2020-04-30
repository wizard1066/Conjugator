//
//  ContentView.swift
//  Conjugator
//
//  Created by localadmin on 20.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let populatePublisher = PassthroughSubject<String?,Never>()
let rulesPublisher = PassthroughSubject<Void,Never>()

var shaker = true
var once = true

enum PersonClass {
  case a1
  case a2
  case a3
  case p1
  case p2
  case p3
  case px
}

struct verbBlob {
  var id:Int!
  var name:String!
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
           print("file exist")
//           let data = try String(contentsOfFile: fileURL!.absoluteString, encoding: .utf8)
           let data = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
//           let myStrings = data.components(separatedBy: .controlCharacters)
           let myStrings = data.components(separatedBy: .newlines)
           return myStrings
           
//           return try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
//            print("contents ",contents)
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
    @State var word:String
    @State var gate:Int?
    var body: some View {
    let letter = word.map( { String($0) } )
    return VStack {
      HStack(spacing:0) {
            ForEach((0 ..< letter.count), id: \.self) { column in
              Text(letter[column])
                .foregroundColor(colorCode(gate: Int(self.gate!), no: column) ? Color.red: Color.black)
                

            }
          }
        }
      }
}

struct ListView: View {
  @Binding var name:String
  @State var device: String
  @State var isSelected: Bool
  
  var body: some View {
    Text(device)
      .listRowBackground(self.isSelected ? Color.yellow: Color.clear)
      .onTapGesture {
        self.name = self.device
        self.isSelected = !self.isSelected
    }
  }
}

struct TextView: View {
  @State var textValue:String!
  @State var textOK = true
  var body: some View {
    if textValue.isEmpty {
      textOK = false
    }
    var twoText = textValue.split(separator: " ")
    if twoText.count == 1 {
      twoText.append(" ")
    }
    return HStack {
        Text(textOK ? twoText[0] : "")
        Text(textOK ? twoText[1] : "")
    }
  }
}

let bsize:CGFloat = 48
let asize:CGFloat = 32
let fsize:CGFloat = 32
let qsize:CGFloat = 20

var ruleColors:[Color] = [Color.blue, Color.purple, Color.green, Color.red, Color(red:255/255, green:105/255, blue:180/255), Color.orange, Color.clear, Color.yellow]
//var verbs: [Int:String] = [7:"Parler",2:"Avoir",70:"Finir",77:"Prendre",81:"Savoir"]
var groups: [Int:String] = [
  1:"Dérivé du radical de l'infinitif",
  2:"Dérivé de l'infinitif complet",
  3:"Dérivé du radical du nous du présent",
  4:"Dérivé du radical du nous du présent",
  5:"Dérivé du radical du ils du présent",
  6:"Dérivé du radical unique du passé simple",
  7:"Dérivé de l'infinitif complet",
  8:"Dérivé du radical du nous du présent",
  9:"Dérivé du radical de l'infinitif",
  10:"Dérivé du radical du ils du présent"
]

var rien = [String](repeating: " ", count: 7)

struct PageTwo: View {
  @EnvironmentObject var env : MyAppEnvironmentData
//  @ObservedObject var verby = verbDB()
//  @ObservedObject var tensey = tenseDB()
//  @ObservedObject var answery = answerDB()
//  @ObservedObject var groupy = groupDB()

  @State var tenses = [
"1-1.Indicatif présent",
"2-2.Indicatif futur",
"3-3.Indicatif imparfait",
"4-4.Indicatif passé simple",
"5-5.Subjonctif Présent",
"6-6.Subjonctif Imparfait",
"7-7.Conditionnel Présent",
"9-8.Participe Présent",
"10-9.Participe Passé",
"20-10.Infinitif Présent"]

  @State var verb:[String] = []
  @State var selectedVerb = 0
  @State var selectedGroup = 0
  
  @State var groupName = ""
  
  @State var selectedTense = 4
  @State var verbSelected = "Conjugator"
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
  
  @State var display1Verb = true
  @State var display1Tense = true
  
  @State var showColor = false
  @State var verbID:Int!
  @State var tenseID:Int!
  @State var personID: PersonClass!
  
  @State var lvalue:Int = 99
  @State var pvalue:Int = 99
  
  @State var isSelect1S = false
  @State var isSelect2S = false
  @State var isSelect3S = false
  @State var isSelect1P = false
  @State var isSelect2P = false
  @State var isSelect3P = false
  
  @State var verbText:String = ""
  @State var answerText:String = ""
  @State var ruleColor: Color = Color.clear
  
  @State var hintOne:String = ""
  @State var hintTwo:String = ""
  @State var hintOneVisible = false
  @State var hintTwoVisible = false
  
  @State var selections:[answerBlob] = []
  @State private var action: Int? = 0
  
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
    
    func findAnswer() -> String? {
      let bob = env.answery.answerx.filter({ verbID == $0.verbID && tenseID == $0.tenseID && personID == $0.personID})
      print("answer [\(bob)]")
      if bob.isEmpty {
        return("")
      } else {
        return bob.first?.name!
      }
    }
    
    func findHint1() -> String? {
      let bob = env.tensey.tensex.filter({ tenseID == $0.id })
      let sue = env.groupy.groupx.filter({ bob.first?.groupID == $0.groupID})
      if bob.isEmpty {
        return("")
      } else {
        return sue.first?.name!
      }
    }
    
    
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
      Spacer().frame(width: 256, height: 0, alignment: .center)
        .navigationBarTitle(Text("Conjugator"), displayMode: .inline).font(Fonts.avenirNextCondensedBold(size: 20))
        .navigationBarItems(trailing: Text("Admin").onTapGesture {
          self.action = 1
          self.env.currentPage = .NavigationView
        })
        .onAppear {
          populatePublisher.send(nil)
        }
//        navlink2.frame(width:0, height:0)
//      Spacer()
      if display0Verb {
        Picker("", selection: $selectedVerb) {
          ForEach((0 ..< env.verby.verbx.count), id: \.self) { column in
            Text(self.env.verby.verbx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 24))
          }
        }.frame(width: 256, height: 162, alignment: .center)
        .onReceive([selectedVerb].publisher.first()) { ( value ) in
          self.verbText = self.env.verby.verbx[value].name
          self.verbID = self.env.verby.verbx[value].id
          self.display0Tense = true
          self.preVerbSelected = self.selectedVerb > 0 ? self.env.verby.verbx[value - 1].name : ""
          self.postVerbSelected = self.selectedVerb < self.env.verby.verbx.count ? self.env.verby.verbx[value + 1].name : ""
          self.verbSelected = self.env.verby.verbx[value].name
          
          
            if value != self.pvalue {
              self.display2Conjugations = false
              self.selections.removeAll()
              for instance in self.env.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.selections.append(instance)
                }
              }
              self.pvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
                self.display2Conjugations = true
                self.display0Tense = true
                self.display0Verb = false
              }
            }
          
        }
        .labelsHidden()
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      } else {
        if display1Verb {
          VStack(spacing: 0) {
            VerbView(display0Verb: $display0Verb, preVerbSelected: $preVerbSelected, verbSelected: $verbSelected, postVerbSelected: $postVerbSelected)
          }
        }
      }

      
      if display0Tense {
        Picker("", selection: $selectedTense) {
          ForEach((0 ..< self.env.tensey.tensex.count), id: \.self) { column in
            //        ForEach(0 ..< tenses.count) {
            Text(self.env.tensey.tensex[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 24))
              .background(self.showColor ? Color.yellow: Color.clear)
          }
        }.labelsHidden()
          .frame(width: 256, height: 162, alignment: .center)
          .onReceive([selectedTense].publisher) { ( value ) in
            self.display1Verb = false
            self.tenseID = self.env.tensey.tensex[value].id
            self.groupName = self.env.groupy.groupx[value].name
            
            self.preTenseSelected = self.selectedTense > 0 ? self.env.tensey.tensex[value - 1].name : ""
            self.postTenseSelected = self.selectedTense < self.env.tensey.tensex.count ? self.env.verby.verbx[value + 1].name : ""
            self.tenseSelected = self.env.tensey.tensex[value].name
            if value != self.lvalue {
              self.display2Conjugations = false
              self.display1Verb = false
              self.selections.removeAll()
              for instance in self.env.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.selections.append(instance)
                }
              }
              self.selections.sort { (first, second) -> Bool in
                  first.personID.debugDescription < second.personID.debugDescription
                }
              
              self.lvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display2Conjugations = true
                self.display0Tense = false
                self.display0Verb = false
                self.display1Verb = true
              }
            }
//          }
        }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      }
      else {
        if display1Tense {
          VStack(spacing: 0) {
            TenseView(display0Tense: $display0Tense, preTenseSelected: $preTenseSelected, tenseSelected: $tenseSelected, postTenseSelected: $postTenseSelected)
          }
        }
      }
      Text(groupName)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.yellow)
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      if display2Conjugations {
        List {
            ForEach((0 ..< self.selections.count), id: \.self) { column in
              newView(word: self.selections[column].name, gate: self.selections[column].redMask!)
              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
              .font(Fonts.avenirNextCondensedBold(size: 22))
          }
        }.environment(\.defaultMinListRowHeight, 20)
        .environment(\.defaultMinListHeaderHeight, 0)
        .frame(width: 256, height: 180, alignment: .center)
        
      }
    } // VStack
    .onReceive(rulesPublisher, perform: { ( _ ) in
      self.display0Verb = false
      self.env.verby.verbx.removeAll()
      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
      for instance in dictSortByValue {
        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        self.env.groupy.groupx.append(newGroup)
      }
    })
    .onReceive(populatePublisher, perform: { ( seek ) in
      self.display0Verb = false
      self.display0Tense = false
      self.display2Conjugations = false
        
      
      
        if once {
          once = false
               
      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
      for instance in dictSortByValue {
        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        self.env.groupy.groupx.append(newGroup)
      }
      
      for instance in self.tenses {
        let breakout = instance.split(separator: ".")
        let breakdown = breakout[0].split(separator: "-")
        let newTense = tenseBlob(id: Int(breakdown[0]), groupID: Int(breakdown[1]), name: String(breakout[1]))
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
    })
    
    
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
  @Binding var preTenseSelected:String
  @Binding var tenseSelected:String
  @Binding var postTenseSelected:String
  
  var body: some View {
    VStack {
            Text(preTenseSelected)
            .font(Fonts.avenirNextCondensedBold(size: 24))
            .onLongPressGesture {
              self.display0Tense.toggle()
              //            self.display0Tense.toggle()
          }
          .opacity(0.1)
          .rotation3DEffect(.degrees(20), axis: (x: 1, y: 0, z: 0))
          Text(tenseSelected)
            .font(Fonts.avenirNextCondensedBold(size: 24))
            .onLongPressGesture {
              self.display0Tense.toggle()
              //            self.display0Tense.toggle()
          }
          Text(postTenseSelected)
            .font(Fonts.avenirNextCondensedBold(size: 24))
            .onLongPressGesture {
              self.display0Tense.toggle()
              //            self.display0Tense.toggle()
          }
          .opacity(0.1)
          .rotation3DEffect(.degrees(20), axis: (x: -1, y: 0, z: 0))
        }
        }
}
  
struct VerbView: View {
  @Binding var display0Verb:Bool
  @Binding var preVerbSelected:String
  @Binding var verbSelected:String
  @Binding var postVerbSelected:String
  
  var body: some View {
    VStack {
      Text(preVerbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display0Verb.toggle()
          //            self.display0Tense.toggle()
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(20), axis: (x: 1, y: 0, z: 0))
      Text(verbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display0Verb.toggle()
          //            self.display0Tense.toggle()
      }
      Text(postVerbSelected)
        .font(Fonts.avenirNextCondensedBold(size: 24))
        .onLongPressGesture {
          self.display0Verb.toggle()
          //            self.display0Tense.toggle()
      }
      .opacity(0.1)
      .rotation3DEffect(.degrees(20), axis: (x: -1, y: 0, z: 0))
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
