//
//  ListView.swift
//  Conjugator
//
//  Created by localadmin on 08.05.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

struct ListView: View {
  @EnvironmentObject var env: MyAppEnvironmentData
  
  var body: some View {
    var verbView = [String]()
    var colorView = [Int]()
    var selections = [AnswerBlob]()
    for idx in 0..<env.verby.verbx.count {
      if env.verby.verbx[idx].id < 99 {
        for idx2 in 0..<env.tensey.tensex.count {
          verbView.append(env.verby.verbx[idx].name + " - " + env.tensey.tensex[idx2].name)
          colorView.append(0)
          verbID = env.verby.verbx[idx].id
          tenseID = env.tensey.tensex[idx2].id
          selections = returnDB(tenseID: tenseID, verbID: verbID, environment: env)
          for idx3 in 0..<selections.count {
            verbView.append(selections[idx3].name)
            colorView.append(selections[idx3].redMask!)
          }
        }
      }
    }
    return VStack {
//      Text("ListView")
      Text(self.env.switchLanguage ? "All Model Verbs": "Tous verbes modèles")
      .font(Fonts.avenirNextCondensedBold(size: 32))
      List {
        ForEach((0 ..< verbView.count), id: \.self) { column1 in
          TableView(word: verbView[column1], gate: colorView[column1])
            .font(Fonts.avenirNextCondensedBold(size: 20))
//          Text(verbView[column1])
//          TenseList(column1: column1)
//          Text(self.env.verby.verbx[column].name)
//          ForEach ((0 ..< env.tensey.tensex.count), id: \.self) { column in
//              Text(self.env.tensey.tensex[column].name)
        }
      }.environment(\.defaultMinListRowHeight, 20)
          .environment(\.defaultMinListHeaderHeight, 0)
          
    }
  }
}

struct TableView: View {
  
//  @EnvironmentObject var env : MyAppEnvironmentData
  @State var word: String
  @State var gate: Int?
  
  var body: some View {
    let letter = word.map({String($0)})
    
    return VStack {
      HStack(spacing: 0) {
        ForEach((0 ..< letter.count), id: \.self) { column in
          Text(letter[column])
            .foregroundColor(colorCode(gate: Int(self.gate!), noX: column) ? Color.red: Color.black)
        }
      }
     }
    }
}

func returnDB(tenseID: Int, verbID: Int, environment: MyAppEnvironmentData) -> [AnswerBlob] {
  var selections = [AnswerBlob]()
  for instance in environment.answery.answerx {
      if instance.tenseID == tenseID && instance.verbID == verbID {
          selections.append(instance)
      }
    }
    selections.sort { (first, second) -> Bool in
      first.personID.debugDescription < second.personID.debugDescription
    }
    return selections
}

struct LineView: View {
  @State var display: String
  var body: some View {
    Text(display)
  }
}
