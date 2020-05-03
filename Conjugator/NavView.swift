//
//  NavView.swift
//  Conjugator
//
//  Created by localadmin on 28.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation


enum MyAppPage {
  case Menu
  case SecondPage
  case NavigationView
}

final class MyAppEnvironmentData: ObservableObject {
  @Published var currentPage : MyAppPage? = .Menu
  @Published var level:String = "model"
  @Published var verby = verbDB()
  @Published var tensey = tenseDB()
  @Published var answery = answerDB()
//  @Published var groupy = groupDB()
  @Published var switchLanguage:Bool = false
}

var prime = true

struct NavigationTest: View {
  
  var body: some View {
    NavigationView {
      PageOne()
    }
  }
}

class PlayerUIView: UIView {
  private let playerLayer = AVPlayerLayer()
  override init(frame: CGRect) {
    super.init(frame: .zero)
    let url = Bundle.main.url(forResource:"finalV3", withExtension: "mov")
//    let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
//    let url = URL(string: "https://www.youtube.com/watch?v=XK8METRgK_U")!
    let player = AVPlayer(url: url!)
    player.play()
    
    playerLayer.player = player
    layer.addSublayer(playerLayer)
  }
  required init?(coder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = UIScreen.main.bounds
  }
}

struct PlayerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }
  func makeUIView(context: Context) -> UIView {
    return PlayerUIView(frame: .zero)
  }
}


struct PageOne: View {
  @EnvironmentObject var env : MyAppEnvironmentData
//  @State private var switchLanguage = false
  @State private var intro2Do = true
  
  var body: some View {
    let navlink = NavigationLink(destination: PageTwo(),
                                 tag: .SecondPage,
                                 selection: $env.currentPage,
                                 label: { EmptyView() })
    
    return VStack {
      ZStack {
        Rectangle()
        .fill(Color.yellow)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
//        PlayerView()
      }
      Group {
      
      Text(env.switchLanguage ? "Conjugator":"Conjugateur")
        .font(Fonts.avenirNextCondensedBold(size: 32))
        .padding()
        .modifier(DownLoadConjugations())
      
      navlink
        .frame(width:0, height:0)
      }
      
      Button(env.switchLanguage ? "Model Verbs":"Verbes Modèles") {
          DownLoadVerbs(levels:["model"], environment: self.env)
          self.intro2Do = false
          self.env.level = "model"
          
//          self.env.currentPage = .SecondPage
          
        }
//        .border(Color.primary)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
      
      
      Button(env.switchLanguage ? "Beginner":"Débutant") {
          self.env.level = "easy"
          DownLoadVerbs(levels:["easy"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
//        .border(Color.primary)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)
        
        Button(env.switchLanguage ? "Intermediate":"Intermédiaire") {
          self.env.level = "medium"
          DownLoadVerbs(levels:["medium"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
//        .border(Color.primary)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)
        
        Button(env.switchLanguage ? "Advanced": "Avancé") {
          self.env.level = "hard"
          DownLoadVerbs(levels:["hard"], environment: self.env)
          self.env.currentPage = .SecondPage
        }
//        .border(Color.primary)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)
        
        Button(env.switchLanguage ? "Superior":"Supérieur") {
          DownLoadVerbs(levels:["easy","medium","hard","dynamic","model"], environment: self.env)
          self.env.level = "hard"
          self.env.currentPage = .SecondPage
        }
//        .border(Color.primary)
        .font(Fonts.avenirNextCondensedBold(size: 20))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .disabled(intro2Do)
        
        Spacer()
        HStack {
        Spacer()
          Text(env.switchLanguage ? "French":"Français")
            .font(Fonts.avenirNextCondensedBold(size: 10))
          Toggle("French", isOn: $env.switchLanguage)
            .font(Fonts.avenirNextCondensedBold(size: 10))
            .labelsHidden()
          Text(env.switchLanguage ? "English":"Anglais")
            .font(Fonts.avenirNextCondensedBold(size: 10))
        Spacer()
      }.padding()
    }
  }
  
}

func DownLoadVerbs(levels:[String], environment: MyAppEnvironmentData) {
  
  environment.verby.verbx.removeAll()
  
  
  print("downloading ... ",environment.level)
  
    let content = readVerb(fileName: "verb")
    
    for lines in content! {
      if lines.count > 1 {
        for level in levels {
          let verb = lines.split(separator: ",")
          let index = Int(String(verb[0]))
          let link = Int(String(verb[2]))
          let stage = String(verb[3])
          if level == stage {
            let newVerb = verbBlob(id: index, name: String(verb[1]), link: link)
            environment.verby.verbx.append(newVerb)
          }
      }
    }
  }
  let french = Locale(identifier: "fr-CH")
  environment.verby.verbx.sort { (first, second) -> Bool in
    (first.name!.compare(second.name!, locale: french)) == .orderedAscending
  }
}

struct DownLoadConjugations: ViewModifier {
  @EnvironmentObject var env : MyAppEnvironmentData
  func body(content: Content) -> some View {
    content
      .onAppear {
        if prime {
          prime = false
        self.env.tensey.tensex.removeAll()
//        self.env.groupy.groupx.removeAll()
        self.env.answery.answerx.removeAll()
        
        let content2 = readConjugations()
        
        for lines in content2! {
          if lines.count > 1 {
//            print("verb ",lines)
            
            let tense = lines.split(separator: ",")
            
            if lines.contains("abso") {
              print("tense ",tense)
            }
            
            let verbID = Int(String(tense[1]))
            let tenseID = Int(String(tense[2]))
            let conjugation = String(tense[5] + " " + tense[6])
            //            for instance in self.answers {
            let personID = returnClass(class2C: String(tense[5]))
//            //        print("conjugation ",conjugation)
//            switch tense[5] {
//            case "Je":
//              personID = PersonClass.a1
//              break
//            case "J'":
//              personID = PersonClass.a1
//              break
//            case "Tu":
//              personID = PersonClass.a2
//              break
//            case "Il":
//              personID = PersonClass.a3
//              break
//            case "Nous":
//              personID = PersonClass.b1
//              break
//            case "Vous":
//              personID = PersonClass.b2
//              break
//            case "Ils":
//              personID = PersonClass.a4
//              break
//            default:
//              break
//            }
            
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
}

func returnClass(class2C:String) -> PersonClass {
   var personID:PersonClass!
            //        print("conjugation ",conjugation)
            switch class2C {
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
              personID = PersonClass.b1
              break
            case "Vous":
              personID = PersonClass.b2
              break
            case "Ils":
              personID = PersonClass.a4
              break
            default:
              personID = PersonClass.cx
            }
    return personID
}

#if DEBUG
struct NavigationTest_Previews: PreviewProvider {
  static var previews: some View {
    NavigationTest().environmentObject(MyAppEnvironmentData())
  }
}
#endif


