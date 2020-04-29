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
  
//  @State var answer = [String](repeating: "", count: 7)
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
  
  @State var selections:[answerBlob] = []
  
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
    
    
    let navlink2 = NavigationLink(destination: AdminView(),
                       tag: .NavigationView,
                       selection: $env.currentPage,
                       label: { EmptyView() })
                       
    let design = UIFontDescriptor.SystemDesign.rounded
    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                                     .withDesign(design)!
    let font = UIFont.init(descriptor: descriptor, size: 48)
    UINavigationBar.appearance().largeTitleTextAttributes = [.font : font]
    
    return VStack(alignment: .center) {
      Spacer().frame(width: 256, height: 0, alignment: .center)
        .navigationBarTitle(Text("Conjugator"), displayMode: .inline).font(Fonts.avenirNextCondensedBold(size: 20))
        .navigationBarItems(trailing: Text("Admin").onTapGesture {
          print("page3")
          
          self.env.currentPage = .NavigationView
        })
        .onAppear {
          populatePublisher.send(nil)
        }
        navlink2.frame(width:0, height:0)
//      Spacer()
      if display0 {
        Picker("", selection: $selectedVerb) {
          ForEach((0 ..< env.verby.verbx.count), id: \.self) { column in
            Text(self.env.verby.verbx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 24))
          }
        }.frame(width: 256, height: 162, alignment: .center)
        .onReceive([selectedVerb].publisher.first()) { ( value ) in
          self.verbText = self.env.verby.verbx[value].name
          self.verbSelected = self.env.verby.verbx[value].name
          self.verbID = self.env.verby.verbx[value].id
          if shaker {
            if value != self.pvalue {
              self.display2 = false
              self.selections.removeAll()
              for instance in self.env.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.selections.append(instance)
                }
              }
              self.pvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display2 = true
                self.display1 = true
                self.display0 = false
              }
            }
          }
        }
        .labelsHidden()
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      } else {
        Text(verbSelected)
          .font(Fonts.avenirNextCondensedBold(size: 24))
          .onLongPressGesture {
            self.display0.toggle()
            self.display1.toggle()
          }
      }

      
      if display1 {
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

            self.tenseID = self.env.tensey.tensex[value].id
            self.groupName = self.env.groupy.groupx[value].name
            if value != self.lvalue {
              self.display2 = false
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
                self.display2 = true
              }
            }
//          }
        }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      }
//      else {
//        Spacer()
//      }
      Text(groupName)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .background(Color.yellow)
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      if display2 {
        List {
            ForEach((0 ..< self.selections.count), id: \.self) { column in
              newView(word: self.selections[column].name, gate: self.selections[column].redMask!)
              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
              .font(Fonts.avenirNextCondensedBold(size: 22))
          }
        }.environment(\.defaultMinListRowHeight, 20)
        .environment(\.defaultMinListHeaderHeight, 0)
        .frame(width: 256, height: 180, alignment: .center)
        
      } else {
          List {
            ForEach(0 ..< rien.count) {
              Text(rien[$0])
              .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 0))
              .font(Fonts.avenirNextCondensedBold(size: 22))
            }
        }.frame(width: 256, height: 180, alignment: .center)
      }
      
    } // VStack
    .onReceive(rulesPublisher, perform: { ( _ ) in
      self.display0 = false
      self.env.verby.verbx.removeAll()
      let dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
      for instance in dictSortByValue {
        let newGroup = groupBlob(groupID: instance.key, name: instance.value)
        self.env.groupy.groupx.append(newGroup)
      }
    })
    .onReceive(populatePublisher, perform: { ( seek ) in
      self.display0 = false
      self.display1 = false
      self.display2 = false
        
      
      
        if once {
          once = false
          
          self.env.verby.verbx.removeAll()
          
          let content = readVerb(fileName: self.env.level)
        
          for lines in content! {
            if lines.count > 1 {
              
              let verb = lines.split(separator: ",")
              let index = Int(String(verb[0]))
              let newVerb = verbBlob(id: index, name: String(verb[1]))
              self.env.verby.verbx.append(newVerb)
              
            }
            self.env.verby.verbx.sort { (first, second) -> Bool in
              first.name < second.name
            }
          }
        
          self.env.tensey.tensex.removeAll()
          self.env.groupy.groupx.removeAll()
          self.env.answery.answerx.removeAll()
        
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
//        print("conjugation ",conjugation)
        switch tense[5] {
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
        
        if redMask == nil {
          redMask = 0
        }
        

            if verbID != nil {
//              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation)
              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              self.env.answery.answerx.append(newAnswer)
            }
          }
      }
      

      
      var dictSortByValue = groups.sorted(by: {$0.value < $1.value} )
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
        self.display0 = true
//        self.display1 = true
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
