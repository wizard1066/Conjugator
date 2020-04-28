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
  
  @State var verbID:Int!
  @State var tenseID:Int!
  @State var personID: PersonClass!
  @State var groupName: String!
  
  @State var lvalue:Int = 99
  @State var pvalue:Int = 99
  
  @State var answer = [String](repeating: "", count: 7)
  @State var colors = [Int](repeating: 0, count: 7)
  @State var select = [Bool](repeating: false, count: 7)
  @State var choice = [Bool](repeating: false, count: 50)
  @State var selectedAnswer = 0
  @State var verbText = ""
  
  @State var display9 = false
  @State var display0 = true
  @State var display1 = false
  @State var display2 = false
  @State var display3 = false
  
  @State private var location = ""
  @State private var tag = 0
  
  @EnvironmentObject var env : MyAppEnvironmentData
  
  var body: some View {
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
                self.display2 = false
                var count = 0
                self.answer.removeAll()
                for instance in self.env.answery.answerx {
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
                  self.display9 = true
                }
              }
            }
        }
        
        ForEach((0 ..< answer.count), id: \.self) { column in
          HStack(spacing:0) {
          ForEach(Array(self.answer[column]), id: \.self) { row in
            Text(self.display9 ? String(row):"")
              .font(Fonts.avenirNextCondensedBold(size: 18))
              .onTapGesture {
                self.tag = column
                self.select[column].toggle()
            }
            .background(self.select[column] ? Color.yellow: Color.clear)
            .foregroundColor(self.choice[column] ? Color.red: Color.black)
          }
        }
        }
        HStack {
          ForEach((0 ..< 16), id: \.self) { column in
            Text("O")
              .font(Fonts.avenirNextCondensedBold(size: 20))
              .onTapGesture {
                print("tag ",self.tag)
                self.choice[self.tag].toggle()
            }
            .border(Color.gray)
          }
        }
        
        
        Picker("", selection: $selectedTense) {
          ForEach((0 ..< self.env.tensey.tensex.count), id: \.self) { column in
            Text(self.env.tensey.tensex[column].name)
              .font(Fonts.avenirNextCondensedBold(size: 18))
          }
        }.labelsHidden()
          .onReceive([selectedTense].publisher) { ( value ) in
            //            print("+++value+++",value)
            //            if value > 0 {
            self.tenseID = self.env.tensey.tensex[value].id
            self.groupName = self.env.groupy.groupx[value].name
            //            self.answerText = findAnswer()!
            if value != self.lvalue {
              self.display2 = false
              
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
                self.display2 = true
              }
            }
        }
    }
  }
  
}
