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
  @EnvironmentObject var env : MyAppEnvironmentData
  
  var body: some View {
    VStack {
      Text("ListView")
      List {
        ForEach((0 ..< env.verby.verbx.count), id: \.self) { column1 in
          TenseList(column1: column1)
//          Text(self.env.verby.verbx[column].name)
//          ForEach ((0 ..< env.tensey.tensex.count), id: \.self) { column in
//              Text(self.env.tensey.tensex[column].name)
        }
      }
    }
  }
}

struct TenseList: View {
  @State var column1: Int
  @EnvironmentObject var env : MyAppEnvironmentData
  var body: some View {
    VStack {
//      List {
        ForEach ((0 ..< env.tensey.tensex.count), id: \.self) { column2 in
//          Text(self.env.verby.verbx[self.column1].name + self.env.tensey.tensex[column2].name)
          DataList(column1: self.column1, column2: column2)
//        }
      }
    }
  }
}

var selections = [answerBlob]()

struct DataList: View {
  @State var column1: Int
  @State var column2: Int
  @State var display = false
  @EnvironmentObject var env : MyAppEnvironmentData
  var body: some View {
    selections = returnDB(tenseID: column2, verbID: column1, environment: env)
    return VStack {
      LineView(display: display ? selections[0].name : "")
    }
  }
}

func returnDB(tenseID: Int, verbID: Int, environment: MyAppEnvironmentData) -> [answerBlob]{
  var selections = [answerBlob]()
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
