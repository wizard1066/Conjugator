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

var shaker = false
var once = true

enum PersonClass {
  case s1
  case s2
  case s3
  case p1
  case p2
  case p3
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
    @State var gate:Int
    var body: some View {
    let letter = word.map( { String($0) } )
    return VStack {
      HStack(spacing:0) {
            ForEach((0 ..< letter.count), id: \.self) { column in
              Text(letter[column])
                .foregroundColor(colorCode(gate: Int(self.gate), no: column) ? Color.red: Color.black)
                

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
  10:"Rien"
]

var rien = [String](repeating: " ", count: 7)

struct ContentView: View {
  @ObservedObject var verby = verbDB()
  @ObservedObject var tensey = tenseDB()
  @ObservedObject var answery = answerDB()
  @ObservedObject var groupy = groupDB()
//  @State var verbs = ["7-7.Parler",25:"Avoir",70:"Finir",77:"Prendre",81:"Savoir"]
  @State var tenses = ["1-1.Présent de l'indicatif",
"2-2.Futur Simple",
"3-3.Imparfait de l'Indicatif",
"4-4.Passé Simple",
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
  
  @State var answer = [String](repeating: "", count: 7)
  @State var colors = [Int](repeating: 0, count: 7)
  @State var selectedAnswer = 0
  
  @State var blanks = [String](repeating: "", count: 7)
  @State var display0 = false
  @State var display1 = false
  @State var display2 = false
  @State var display3 = false
  
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
      let zak = answery.answerx.firstIndex { ( data ) -> Bool in
          data.personID == personID && data.verbID == verbID && data.tenseID == tenseID
        }
      return zak
    }
    
    func findAnswer() -> String? {
      let bob = answery.answerx.filter({ verbID == $0.verbID && tenseID == $0.tenseID && personID == $0.personID})
      print("answer [\(bob)]")
      if bob.isEmpty {
        return("")
      } else {
        return bob.first?.name!
      }
    }
    
    func findHint1() -> String? {
      let bob = self.tensey.tensex.filter({ tenseID == $0.id })
      let sue = self.groupy.groupx.filter({ bob.first?.groupID == $0.groupID})
      if bob.isEmpty {
        return("")
      } else {
        return sue.first?.name!
      }
    }
    
    
    
    
    return VStack(alignment: .center) {
      Spacer().frame(height:40)
//      Spacer()
      if display0 {
           Picker("", selection: $selectedVerb) {
          ForEach((0 ..< verby.verbx.count), id: \.self) { column in
            Text(self.verby.verbx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 20))
          }
        }.frame(width: 256, height: 100, alignment: .center)
        .onReceive([selectedVerb].publisher.first()) { ( value ) in
          self.verbText = self.verby.verbx[value].name
          self.verbID = self.verby.verbx[value].id
//          self.answerText = findAnswer()!
//          print("** value ** ",value)
          if shaker {
            if value != self.pvalue {
              self.display2 = false
              var count = 0
              self.answer.removeAll()
              for instance in self.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.answer.append(instance.name)
                  if instance.redMask != nil {
                    self.colors.append(instance.redMask!)
                  } else {
                    self.colors.append(0)
                  }
//                  print("self.answer ",instance)
                  count += 1
                }
              }
              self.pvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display2 = true
              }
            }
          }
        }
        .labelsHidden()
      } else {
        Picker("", selection: $selectedAnswer) {
          ForEach(0 ..< blanks.count) {
            Text(self.blanks[$0])
              .font(Fonts.avenirNextCondensedBold(size: 16))
          }
          
          
        }.labelsHidden()
          .frame(width: 256, height: 100, alignment: .center)
      }

      Spacer().frame(height: 100)
      
      if display1 {
        Picker("", selection: $selectedTense) {
          ForEach((0 ..< tensey.tensex.count), id: \.self) { column in
            //        ForEach(0 ..< tenses.count) {
            Text(self.tensey.tensex[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 20))
              .background(self.showColor ? Color.yellow: Color.clear)
          }
        }.labelsHidden()
          .frame(width: 256, height: 100, alignment: .center)
          .onReceive([selectedTense].publisher) { ( value ) in
            print("+++value+++",value)
//            if value > 0 {
            self.tenseID = self.tensey.tensex[value].id
            self.groupName = self.groupy.groupx[value].name
//            self.answerText = findAnswer()!
            if value != self.lvalue {
              self.display2 = false
              var count = 0
              self.answer.removeAll()
              self.colors.removeAll()
              for instance in self.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.answer.append(instance.name)
                  if instance.redMask != nil {
                    self.colors.append(instance.redMask!)
                  } else {
                    self.colors.append(0)
                  }
                  print("self.answer ",instance)
                  count += 1
                }
              }
              self.lvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display2 = true
              }
            }
//          }
        }
      } else {
        Picker("", selection: $selectedGroup) {
          ForEach((0 ..< groupy.groupx.count), id: \.self) { column in
            Text(self.groupy.groupx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 20))
          }
        }.onReceive([selectedGroup].publisher.first()) { ( value ) in
            print("selectedGroup ",self.selectedGroup)

        }
        .labelsHidden()
        .frame(width: 256, height: 90, alignment: .center)
      }
      Text(groupName)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.yellow)
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 8, trailing: 0))
//      Spacer()
      if display2 {
        List {
//          ForEach(0 ..< answer.count) {
            ForEach((0 ..< self.answer.count), id: \.self) { column in
              newView(word: self.answer[column], gate: self.colors[column])
//          Text(self.answer[column]).onAppear(perform: {
//            print("colors ",self.colors[column],column)
//          })
              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
              .font(Fonts.avenirNextCondensedBold(size: 20))
             
//            TextView(textValue: self.answer[$0])
//              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
//              .font(Fonts.avenirNextCondensedBold(size: 20))
              

          }
        }.environment(\.defaultMinListRowHeight, 20)
        .environment(\.defaultMinListHeaderHeight, 10)
        .frame(width: 256, height: 180, alignment: .center)
      } else {
          List {
            ForEach(0 ..< rien.count) {
              Text(rien[$0])
              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
              .font(Fonts.avenirNextCondensedBold(size: 20))
            }
        }
      }
      Spacer().frame(height: 24)
    } // VStack
    .onReceive(rulesPublisher, perform: { ( _ ) in
      self.display0 = false
      self.verby.verbx.removeAll()
      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
      for instance in dictSortByValue {
        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        self.groupy.groupx.append(newGroup)
      }
    })
    .onReceive(populatePublisher, perform: { ( seek ) in
      self.display0 = false
      self.display1 = false
      self.display2 = false
      
      
      
//      print("verbs ",verbs)
      // fuck
      if once {
        once = false
        
      self.verby.verbx.removeAll()
      self.tensey.tensex.removeAll()
      self.verby.verbx.removeAll()
      self.groupy.groupx.removeAll()
        
        let content = readVerb(fileName: "hard")
      
        for lines in content! {
          if lines.count > 1 {
            print("verb ",lines)
            let verb = lines.split(separator: ",")
            let index = Int(String(verb[0]))
            let newVerb = verbBlob(id: index, name: String(verb[1]))
            self.verby.verbx.append(newVerb)
          }
          self.verby.verbx.sort { (first, second) -> Bool in
            first.name < second.name
          }
        }
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
            print("verb ",lines)
            let tense = lines.split(separator: ",")
            let verbID = Int(String(tense[1]))
            let tenseID = Int(String(tense[2]))
            let conjugation = String(tense[5] + " " + tense[6])
//            for instance in self.answers {
        var personID:PersonClass!
        print("conjugation ",conjugation)
        switch tense[5] {
          case "Je":
            personID = PersonClass.s1
            break
          case "J'":
            personID = PersonClass.s1
            break
          case "Tu":
            personID = PersonClass.s2
            break
          case "il":
            personID = PersonClass.s3
            break
          case "Nous":
            personID = PersonClass.p1
            break
          case "Vous":
            personID = PersonClass.p2
            break
          case "Ils":
            personID = PersonClass.p3
            break
          default:
            break
        }

        

      
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
        print("redMask ",redMask)
        

            if verbID != nil {
//              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation)
              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              self.answery.answerx.append(newAnswer)
            }
          }
      }
      

      
      var dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
      for instance in dictSortByValue {
        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        self.groupy.groupx.append(newGroup)
      }
      
      for instance in self.tenses {
        let breakout = instance.split(separator: ".")
        let breakdown = breakout[0].split(separator: "-")
        let newTense = tenseBlob(id: Int(breakdown[0]), groupID: Int(breakdown[1]), name: String(breakout[1]))
        self.tensey.tensex.append(newTense)
      }
      
      self.tensey.tensex.sort { (first, second) -> Bool in
            first.name < second.name
          }
      }
      
      if seek != nil {
        self.selectedVerb = self.verby.verbx.firstIndex(where: { ( data ) -> Bool in
          seek == data.name
        })!
      }
      

      DispatchQueue.main.asyncAfter(deadline: .now() + Double(2)) {
        shaker = true
        self.display0 = true
        self.display1 = true
        self.display2 = true
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


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      //      print("Device shaken")
      populatePublisher.send(nil)
    }
  }
}

extension String {
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }

        return String(repeating: character, count: padCount) + self
    }
}
