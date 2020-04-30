//
//  NavView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine


enum MyAppPage {
  case Menu
  case SecondPage
  case NavigationView
}

final class MyAppEnvironmentData: ObservableObject {
  @Published var currentPage : MyAppPage? = .Menu
  @Published var level:String = "easy"
  @Published var verby = verbDB()
  @Published var tensey = tenseDB()
  @Published var answery = answerDB()
  @Published var groupy = groupDB()
}

struct NavigationTest: View {
  
  var body: some View {
    NavigationView {
      PageOne()
    }
  }
}


struct PageOne: View {
  @EnvironmentObject var env : MyAppEnvironmentData
  
  
  var body: some View {
    let navlink = NavigationLink(destination: PageTwo(),
                                 tag: .SecondPage,
                                 selection: $env.currentPage,
                                 label: { EmptyView() })
    
    return VStack {
      Group {
      Text("Conjugator")
        .font(Fonts.avenirNextCondensedBold(size: 32))
        .padding()
        .modifier(DownLoadConjugations())
      
      navlink
        .frame(width:0, height:0)
      }
      Spacer()
      Button("Random") {
        DownLoadVerbs(levels:["easy","medium","hard"], environment: self.env)
        self.env.level = "hard"
        self.env.currentPage = .SecondPage
      }
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      .border(Color.primary)
      .font(Fonts.avenirNextCondensedBold(size: 20))
//      .modifier(DownLoadVerbs(levels:["easy","medium","hard"]))
      
      
      Spacer()
      Button("Hard") {
        DownLoadVerbs(levels:["hard"], environment: self.env)
        self.env.level = "hard"
        self.env.currentPage = .SecondPage
      }
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      .border(Color.primary)
      .font(Fonts.avenirNextCondensedBold(size: 20))
//      .modifier(DownLoadVerbs(levels:["hard"]))
      
      Spacer()
        .frame(width: 1, height: 10, alignment: .center)
      Button("Medium") {
        DownLoadVerbs(levels:["medium"], environment: self.env)
        self.env.level = "medium"
        self.env.currentPage = .SecondPage
      }
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      .border(Color.primary)
      .font(Fonts.avenirNextCondensedBold(size: 20))
//      .modifier(DownLoadVerbs(levels:["medium"]))
      
      
      Spacer()
        .frame(width: 1, height: 10, alignment: .center)
      Button("Easy") {
        DownLoadVerbs(levels:["easy"], environment: self.env)
        self.env.level = "easy"
        self.env.currentPage = .SecondPage
      }
      .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      .border(Color.primary)
      .font(Fonts.avenirNextCondensedBold(size: 20))
      
      Spacer()
    }
  }
  
}

func DownLoadVerbs(levels:[String], environment: MyAppEnvironmentData) {
  
  environment.verby.verbx.removeAll()
  
  
  print("downloading ... ",environment.level)
  
  for level in levels {
    
    let content = readVerb(fileName: level)
    
    for lines in content! {
      if lines.count > 1 {
        let verb = lines.split(separator: ",")
        let index = Int(String(verb[0]))
        let newVerb = verbBlob(id: index, name: String(verb[1]))
        environment.verby.verbx.append(newVerb)
      }
    }
  }
  environment.verby.verbx.sort { (first, second) -> Bool in
    first.name < second.name
  }
}

struct DownLoadConjugations: ViewModifier {
  @EnvironmentObject var env : MyAppEnvironmentData
  func body(content: Content) -> some View {
    content
      .onAppear {
        self.env.tensey.tensex.removeAll()
        self.env.groupy.groupx.removeAll()
        self.env.answery.answerx.removeAll()
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
//            print("verb ",lines)
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
              let newAnswer = answerBlob(verbID: verbID, tenseID: tenseID, personID: personID, name: conjugation, redMask: redMask, stemMask: nil, termMask: nil)
              self.env.answery.answerx.append(newAnswer)
            }
          }
        }
    }
  }
}

#if DEBUG
struct NavigationTest_Previews: PreviewProvider {
  static var previews: some View {
    NavigationTest().environmentObject(MyAppEnvironmentData())
  }
}
#endif
