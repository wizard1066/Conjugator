//
//  AdminView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import Foundation
import SwiftUI

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
  @State var persons = [PersonClass](repeating: PersonClass.px, count: 7)
  @State var select = [Bool](repeating: false, count: 7)
  @State var choice = [Bool](repeating: false, count: 99)
  @State var selections:[answerBlob] = []
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
  @State var word = "123456789ABCDEF"
  @State var sumsum = 0
  
  @EnvironmentObject var env : MyAppEnvironmentData
  
  var body: some View {
    print("self.env.answery.answerx A",self.env.answery.answerx.count)
    return
      
      VStack() {
        
        Picker("", selection: $selectedVerb) {
          ForEach((0 ..< env.verby.verbx.count), id: \.self) { column in
            Text(self.env.verby.verbx[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 18))
          }
        }.labelsHidden()
          .onReceive([selectedVerb].publisher.first()) { ( value ) in
            self.verbText = self.env.verby.verbx[value].name
            self.verbID = self.env.verby.verbx[value].id
            //          self.answerText = findAnswer()!
            //          print("** value ** ",value)
            if shaker {
              if value != self.pvalue {
                self.display9 = false
//                var count = 0
//                self.answer.removeAll()
//                self.colors.removeAll()
//                self.persons.removeAll()
                self.selections.removeAll()
                for instance in self.env.answery.answerx {
                  if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                    self.selections.append(instance)
                    print("instanceX ",instance)
//                    self.selectAnswer = count
//                    self.answer.append(instance.name)
//                    self.persons.append(instance.personID)
//                    if instance.redMask != nil {
//                      self.colors.append(instance.redMask!)
//                    } else {
//                      self.colors.append(0)
//                    }
//                    //                  print("self.answer ",instance)
//                    count += 1
                  }
                }
                self.pvalue = value
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                  self.display9 = true
//                  count = 0
                }
              }
            }
        }
        if display9 {
          ForEach((0 ..< self.selections.count), id: \.self) { column in
            newView(word: self.selections[column].name, gate: self.selections[column].redMask!)
  //            Text(self.display9 ? self.answer[column]:"")
                .font(Fonts.avenirNextCondensedMedium(size: 20))
                .onTapGesture {
                  self.tag = column
                  self.select[column].toggle()
                  self.selectedText = self.selections[column].name
                  self.word = self.selections[column].name
                }
              .background(self.select[column] ? Color.yellow: Color.clear)
          }
        }
        SpotView(word: $word, sumsum: $sumsum)
//        HStack {
//          ForEach((0 ..< 16), id: \.self) { column in
//            Text("O")
//              .font(Fonts.avenirNextCondensedBold(size: 20))
//              .onTapGesture {
//                print("tag ",self.tag,self.tag2)
//                self.choice[self.tag].toggle()
//            }
//            .border(Color.gray)
//          }
//        }
        TextField("Change ...", text: $selectedText, onCommit: {
          self.display9 = false
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
          
          let newAnswer = answerBlob(verbID: self.verbID, tenseID: self.tenseID, personID: self.personID, name: self.selectedText, redMask: self.sumsum, stemMask: nil, termMask: nil)
          print("newAnswer ",newAnswer)
          self.env.answery.answerx.append(newAnswer)
          
          
          DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5)) {
            self.display9 = true
            let bob = self.env.answery.answerx.filter({ self.verbID == $0.verbID && self.tenseID == $0.tenseID })
              print("answer [\(bob)]")
              for bobs in bob {
                  print("bob ",bobs)
              }
//            print("self.env.answery.answerx ",self.env.answery.answerx.count)
          }
        })
          .labelsHidden()
          .frame(width: 256, height: 32, alignment: .center)
          .font(Fonts.avenirNextCondensedMedium(size: 20))
        
        Picker("", selection: $selectedTense) {
          ForEach((0 ..< self.env.tensey.tensex.count), id: \.self) { column in
            Text(self.env.tensey.tensex[column].name)
              .font(Fonts.avenirNextCondensedMedium(size: 16))
          }
        }.labelsHidden()
          .onReceive([selectedTense].publisher) { ( value ) in
            //            print("+++value+++",value)
            //            if value > 0 {
            self.tenseID = self.env.tensey.tensex[value].id
            self.groupName = self.env.groupy.groupx[value].name
            //            self.answerText = findAnswer()!
            if value != self.lvalue {
              self.display9 = false
              
              self.answer.removeAll()
              self.colors.removeAll()
              for instance in self.env.answery.answerx {
                if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
                  self.answer.append(instance.name)
                  if instance.redMask != nil {
                    self.colors.append(instance.redMask!)
                  } else {
                    self.colors.append(0)
                  }
                  print("self.answer ",instance)
                  
                }
              }
              self.lvalue = value
              DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
                self.display9 = true
              }
            }
        }
    }
  }
  
   struct SpotView: View {
    @Binding var word:String
    @Binding var sumsum:Int
    @State var gate:Int = 0
    @State var isReady = false
    @State var code:String = ""
//    @State private var name: String = "Tim"
    
    @State var colors = [Bool](repeating: false, count: 24)
    
    var body: some View {
      let letter = word.map( { String($0) } )
    return VStack {
//      VStack {
//            TextField("RedRed", text: $name, onCommit: {
//              self.gate = Int(self.name)!
//            }).padding()
//        }
      HStack(spacing:0) {
            ForEach((0 ..< letter.count), id: \.self) { column in
              Text(letter[column])
                .foregroundColor(colorCodex(gate: Int(self.gate), no: column) ? Color.red: Color.black)
                .font(Fonts.avenirNextCondensedBold(size: 24))
                .background(self.colors[column] ? Color.yellow : Color.clear)
                .foregroundColor(self.colors[column] ? Color.red : Color.clear)
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
