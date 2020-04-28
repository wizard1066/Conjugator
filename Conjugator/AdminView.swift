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
    @State private var once = true
    @State private var display0 = false
    
    @EnvironmentObject var env : MyAppEnvironmentData
    @ObservedObject var verby = verbDB()
    @ObservedObject var tensey = tenseDB()
    @ObservedObject var answery = answerDB()
    @ObservedObject var groupy = groupDB()
    
    var body: some View {
//       let content = readVerb(fileName: self.env.level)
//
//        for lines in content! {
//          if lines.count > 1 {
//
//            let verb = lines.split(separator: ",")
//            let index = Int(String(verb[0]))
//            let newVerb = verbBlob(id: index, name: String(verb[1]))
//            self.verby.verbx.append(newVerb)
//
//          }
//          self.verby.verbx.sort { (first, second) -> Bool in
//            first.name < second.name
//          }
//          display0 = true
//        }
        return NavigationView {
            Form {
                TextField("Firstname",
                      text: $firstname)
                TextField("Lastname",
                      text: $lastname)
            
//                  Picker("", selection: $selectedVerb) {
//                    ForEach((0 ..< verby.verbx.count), id: \.self) { column in
//                      Text(self.verby.verbx[column].name)
//                      .font(Fonts.avenirNextCondensedBold(size: 20))
//                    }
//                  }
                
        List {
            Text("Verb")
            Text("Tense")
            Text("Person")
              }
            }.navigationBarTitle(Text("Profile"))
        }
    }
}
