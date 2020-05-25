//
//  AdminView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

let nextPublisher = PassthroughSubject<Void,Never>()
let resetPublisher = PassthroughSubject<Void,Never>()

struct AdminView: View {
  @State private var firstname = ""
  @State private var lastname = ""
  @State private var selectedVerb = 0
  @State private var selectedTense = 0
  @State private var selectAnswer = 0
  
  @State var verbID:Int!
  @State var tenseID:Int!
  @State var personID: PersonClass!
  @State var groupName: String!
  
  @State var lvalue:Int = 99
  @State var pvalue:Int = 99
  
  @State var answer = [String](repeating: "", count: 7)
  @State var colors = [Int](repeating: 0, count: 7)
  @State var persons = [PersonClass](repeating: PersonClass.cx, count: 7)
  @State var select = [Bool](repeating: false, count: 7)
  @State var choice = [Bool](repeating: false, count: 99)
  @State var selections:[AnswerBlob] = []
  @State var selectedAnswer = 0
  @State var verbText = ""
  
  @State var selectedText = ""
  
  @State var display9 = false
  @State var display0 = true
  @State var display1 = false
  @State var display2 = false
  @State var display3 = false
  
  @State private var location = ""
  @State private var tag = 0
  @State private var tag2 = 0
  @State private var count = 0
  @State var word = "PRESSME"
  @State var sumsum = 0
  
  
  @EnvironmentObject var env : MyAppEnvironmentData
  
  
  
  var body: some View {
    

    return
      
      VStack(){
        
        
        
        SpotView(word: $word, sumsum: $sumsum, display9: $display9)
          
          .navigationBarTitle(Text("Admin Page"), displayMode: .inline).font(Fonts.avenirNextCondensedBold(size: 20))
          .navigationBarItems(trailing: Text("Do Update").onTapGesture {
            print("Updating ...")
            writeFile(answers: self.env.answery.answerx)
        }).onReceive(nextPublisher) { (_) in
          self.display9 = false
        }
        TextField("Modify ...", text: $selectedText, onCommit: {
        
          print("tenseID ",self.tenseID)
        
          self.display9 = false
          // personID needs to be personClass.px if Infinitif present no 20. tense
          
          self.personID = self.selections[self.tag].personID
          self.verbID = self.selections[self.tag].verbID
          self.tenseID = self.selections[self.tag].tenseID
          let zak = self.env.answery.answerx.firstIndex { ( data ) -> Bool in
            data.personID == self.personID && data.verbID == self.verbID && data.tenseID == self.tenseID
          }
          print("timeout ",self.personID,self.verbID,self.tenseID)
          print("fooBar ",self.env.answery.answerx[zak!])
          self.env.answery.answerx.remove(at: zak!)
          
          self.selections[self.tag].name = self.selectedText
          self.selections[self.tag].redMask = self.sumsum
          self.select[self.tag] = false
          
          let newAnswer = AnswerBlob(verbID: self.verbID, tenseID: self.tenseID, personID: self.personID, name: self.selectedText, redMask: self.sumsum, stemMask: nil, termMask: nil)
          print("newAnswer ",newAnswer)
          self.env.answery.answerx.append(newAnswer)
          
          
          DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
            self.display9 = true
            let bob = self.env.answery.answerx.filter({ self.verbID == $0.verbID && self.tenseID == $0.tenseID })
              print("answer [\(bob)]")
              for bobs in bob {
                  print("bob ",bobs)
              }
          }
        })
          .labelsHidden()
          .frame(width: 256, height: 32, alignment: .center)
          .font(Fonts.avenirNextCondensedBold(size: 30))
          .multilineTextAlignment(.center)
      if !display9 {
        Picker("", selection: $selectedVerb) {
          ForEach((0 ..< env.verby.verbx.count), id: \.self) { column in
            Text(self.env.verby.verbx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 24))
          }
        }.labelsHidden()
          .onReceive([selectedVerb].publisher.first()) { ( value ) in
            self.verbText = self.env.verby.verbx[value].name
            self.verbID = self.env.verby.verbx[value].id
            if shaker {
              if value != self.pvalue {
                self.display9 = false
                self.selections.removeAll()
                for instance in self.env.answery.answerx {
                  if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                    self.selections.append(instance)
                  }
                }
                self.pvalue = value
                self.selections.sort { (first, second) -> Bool in
                  first.personID.debugDescription < second.personID.debugDescription
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                  self.display9 = true
//                  count = 0
                }
              }
            }
        }
        }
        if display9 {
          ForEach((0 ..< self.selections.count), id: \.self) { column in
//            newView(word: self.selections[column].name, gate: self.selections[column].redMask!)
            AdmView(env: self._env, word: self.selections[column].name, gate: self.selections[column].redMask!, selections: self.$selections, display2Conjugations: self.$display9)
                .font(Fonts.avenirNextCondensedMedium(size: 24))
                .onTapGesture {
//                  resetPublisher.send()
                  for select in 0 ..< self.select.count {
                    self.select[select] = false
                  }
                  self.tag = column
                  self.select[column].toggle()
                  self.selectedText = self.selections[column].name
                  self.word = self.selections[column].name
                }
              .background(self.select[column] ? Color.yellow: Color.clear)
              .onReceive(resetPublisher) { (_) in
                for select in 0 ..< self.select.count {
                  self.select[select] = false
                }
              }
          }
        }
        Picker("", selection: $selectedTense) {
          ForEach((0 ..< self.env.tensey.tensex.count), id: \.self) { column in
            Text(self.env.tensey.tensex[column].name)
              .font(Fonts.avenirNextCondensedMedium(size: 24))
          }
        }.labelsHidden()
          .onReceive([selectedTense].publisher) { ( value ) in
            self.tenseID = self.env.tensey.tensex[value].id
//            self.groupName = self.env.groupy.groupx[value].name
            if value != self.lvalue {
              self.display9 = false
              self.selections.removeAll()
              for instance in self.env.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                    self.selections.append(instance)
                    
                }
                for select in 0 ..< self.select.count {
                    self.select[select] = false
                  }
                  
                  if self.word != "PRESSME" {
                    self.selectedText = ""
                    self.word = "1234567890abcedf"
                  }
                 
                
              }
              self.lvalue = value
               self.selections.sort { (first, second) -> Bool in
                  first.personID.debugDescription < second.personID.debugDescription
                }
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display9 = true
              }
            }
        }.onTapGesture {
      UIApplication.shared.endEditing()
      }
    }
  }
  
  struct AdmView: View {
  @EnvironmentObject var env : MyAppEnvironmentData
  @State var word:String
  @State var gate:Int?
  @Binding var selections:[AnswerBlob]
  @Binding var display2Conjugations:Bool
  
  var body: some View {
    let letter = word.map( { String($0) } )
    return VStack {
      HStack(spacing:0) {
        ForEach((0 ..< letter.count), id: \.self) { column in
          Text(letter[column])
            .foregroundColor(colorCode(gate: Int(self.gate!), no: column) ? Color.red: Color.black)
            
          
        }
      }
//      .onTapGesture() {
//
//        if linkID != 0  {
//          //            self.display0Conjugations = false
//          self.selections.removeAll()
//          //            self.display0Conjugations = true
//          DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
//            for instance in self.env.answery.answerx {
//              if instance.tenseID == tenseID && instance.verbID == linkID {
//                self.selections.append(instance)
//              }
//            }
//            self.selections.sort { (first, second) -> Bool in
//              first.personID.debugDescription < second.personID.debugDescription
//            }
//            // fooBar
//            //                  let zee =
//            doDivertPublisher.send(linkID)
//            self.display2Conjugations = true
//          }
//        }
//        }
      
    }
  }
}
  
   struct SpotView: View {
    @Binding var word:String
    @Binding var sumsum:Int
    @State var gate:Int = 0
    @State var isReady = false
    @State var code:String = ""
    @Binding var display9:Bool
    
    @State var colors = [Bool](repeating: false, count: 24)
    
    var body: some View {
    let letter = word.map( { String($0) } )
    return VStack {
      HStack(spacing:0) {
            ForEach((0 ..< letter.count), id: \.self) { column in
              Text(letter[column])
                .foregroundColor(colorCodex(gate: Int(self.gate), no: column) ? Color.red: Color.black)
                .font(Fonts.avenirNextCondensedBold(size: 30))
                .background(self.colors[column] ? Color.yellow : Color.clear)
                .foregroundColor(self.colors[column] ? Color.red : Color.clear)
                .onLongPressGesture {
                  self.display9.toggle()
                }
                .onTapGesture {
                    let code = 1 << column
                    print("code ",code)
                    if self.colors[column] {
                      self.colors[column] = false
                      self.sumsum = (self.sumsum - Int(code))
                    } else {
                      self.colors[column] = true
                      self.sumsum = (self.sumsum + Int(code))
                    }
                    print("sumsum ",self.sumsum)
                }
                .gesture(DragGesture(minimumDistance: 0)
                  .onEnded({ ( value ) in
                    let code = 1 << column
                    print("code ",code)
                    if self.colors[column] {
                      self.colors[column] = false
                      self.sumsum = (self.sumsum - Int(code))
                    } else {
                      self.colors[column] = true
                      self.sumsum = (self.sumsum + Int(code))
                    }
                    print("sumsum ",self.sumsum)
                  })
                )
            }
          }
        }
      }
    }
}


func colorCodex(gate:Int, no:Int) -> Bool {

    let bgr = String(gate, radix:2).pad(with: "0", toLength: 16)
    let bcr = String(no, radix:2).pad(with: "0", toLength: 16)
    let binaryColumn = 1 << no
    
    let value = UInt64(gate) & UInt64(binaryColumn)
    let vr = String(value, radix:2).pad(with: "0", toLength: 16)
    
//    print("bg ",bgr," bc ",bcr,vr)
    return value > 0 ? true:false
  }

func writeFile(answers:[AnswerBlob]) {
//  print("amswerBlob ",answers.count)
  let uuid = UUID().uuidString
  let fileName = "Conjugations-" + uuid
  let dir = try? FileManager.default.url(for: .documentDirectory,
                                         in: .userDomainMask, appropriateFor: nil, create: true)
  
  // If the directory was found, we write a file to it and read it back
  print("Saved ",dir)
  if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
    var lines:String = ""
      for line in answers {
        lines += "\(line.verbID!),\(line.tenseID!),0,\(line.name!),\(line.redMask!)\n"
      }
      do {
        try lines.write(to: fileURL, atomically: false, encoding: .utf8)
      } catch {
        print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
      }
    
   
    //reading
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(4)) {
      var inString = ""
      do {
        inString = try String(contentsOf: fileURL)
        
      } catch {
        print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
      }
//      print("Read from the file: \(inString) ")
    }
    }
}

extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      //      print("Device shaken")
      nextPublisher.send()
    }
  }
}
