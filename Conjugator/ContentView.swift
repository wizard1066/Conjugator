//
//  ContentView.swift
//  Conjugator
//
//  Created by localadmin on 20.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let populatePublisher = PassthroughSubject<Void,Never>()

var shaker = false

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

struct tenseBlob {
  var id:Int!
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
  var name:String!
}

final class answerDB: ObservableObject, Identifiable {
  @Published var answerx:[answerBlob] = [] {
    willSet {
      objectWillChange.send()
    }
  }
}

struct Fonts {
  static func avenirNextCondensedBold (size:CGFloat) -> Font{
    return Font.custom("AvenirNextCondensed-Bold",size: size)
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
  var body: some View {
    var twoText = textValue.split(separator: " ")
    if twoText.count == 1 {
      twoText.append(" ")
    }
      return HStack {
        Text(twoText[0]).background(Color.yellow)
        Text(twoText[1])
      }
  }
}

struct ContentView: View {
  @ObservedObject var verby = verbDB()
  @ObservedObject var tensey = tenseDB()
  @ObservedObject var answery = answerDB()
  @State var verbs = [7:"Parler",25:"Avoir",70:"Finir",77:"Pendre",81:"Savoir"]
  @State var tenses = [1:"Présent de l'indicatif",
  2:"Futur Simple",
  3:"Imparfait de l'Indicatif",
  4:"Passé Simple",
  5:"Subjonctif Présent",
  6:"Subjonctif Imparfait",
  7:"Conditionnel Présent",
  8:"Impératif Présent",
  9:"Participe Présent",
  10:"Participe Passé",
  11:"Passé Composé",
  12:"Futur Antérieur",
  13:"Plus-Que-Parfait",
  14:"Passé Anterieur",
  15:"Subjonctif Passé",
  16:"Subjonctif Plus-Que-Parfait",
  17:"Conditionnel Passé 1",
  18:"Conditionnel Passé 2",
  19:"Impératif Passé",
  20:"Infinitif Présent",
  21:"Infinitif Passé",
  22:"Présent gérondif",
  23:"Passé gérondif"]
  @State var verb:[String] = []
  @State var selectedVerb = 0
  
  @State var selectedTense = 4
  @State var answers = [
  "7-1.Je parle",
"7-1.Tu parles",
"7-1.Il parle",
"7-1.Ils parlent",
"7-1.Nous parlons",
"7-1.Vous parlez",
"7-2.Je parlerai",
"7-2.Tu parleras",
"7-2.Il parlera",
"7-2.Ils parleront",
"7-2.Nous parlerons",
"7-2.Vous parlerez",
"7-3.Je parlais",
"7-3.Tu parlais",
"7-3.Il parlait",
"7-3.Ils parlaient",
"7-3.Nous parlions",
"7-3.Vous parliez",
"7-4.Je parlai",
"7-4.Tu parlas",
"7-4.Il parla",
"7-4.Ils parlèrent",
"7-4.Nous parlâmes",
"7-4.Vous parlâtes",
"7-5.Je parle",
"7-5.Tu parles",
"7-5.Il parle",
"7-5.Ils parlent",
"7-5.Nous parlions",
"7-5.Vous parliez",
"7-6.Je parlasse",
"7-6.Tu parlasses",
"7-6.Il parlât",
"7-6.Ils parlassent",
"7-6.Nous parlassions",
"7-6.Vous parlassiez",
"7-7.Je parlerais",
"7-7.Tu parlerais",
"7-7.Il parlerait",
"7-7.Ils parleraient",
"7-7.Nous parlerions",
"7-7.Vous parleriez",
"7-8.Tu parle",
"7-8.Nous parlons",
"7-8.Vous parlez",
"7-9.parlant ",
"7-10.parlé(s) ",
"7-10.parlée(s) ",
"7-11.J' ai",
"7-11.Tu as",
"7-11.Il a",
"7-11.Ils ont",
"7-11.Nous avons",
"7-11.Vous avez",
"7-12.J' aurai",
"7-12.Tu auras",
"7-12.Il aura",
"7-12.Ils auront",
"7-12.Nous aurons",
"7-12.Vous aurez",
"7-13.J' avais",
"7-13.Tu avais",
"7-13.Il avait",
"7-13.Ils avaient",
"7-13.Nous avions",
"7-13.Vous aviez",
"7-14.J' eus",
"7-14.Tu eus",
"7-14.Il eut",
"7-14.Ils eurent",
"7-14.Nous eûmes",
"7-14.Vous eûtes",
"7-15.J' aie",
"7-15.Tu aies",
"7-15.Il ait",
"7-15.Ils aient",
"7-15.Nous ayons",
"7-15.Vous ayez",
"7-16.J' eusse",
"7-16.Tu eusses",
"7-16.Il eût",
"7-16.Ils eussent",
"7-16.Nous eussions",
"7-16.Vous eussiez",
"7-17.J' aurais",
"7-17.Tu aurais",
"7-17.Il aurait",
"7-17.Ils auraient",
"7-17.Nous aurions",
"7-17.Vous auriez",
"7-18.J' eusse",
"7-18.Tu eusses",
"7-18.Il eût",
"7-18.Ils eussent",
"7-18.Nous eussions",
"7-18.Vous eussiez",
"7-19.Tu aie",
"7-19.Nous ayons",
"7-19.Vous ayez",
"25-1.Je finis",
"25-1.Tu finis",
"25-1.Il finit",
"25-1.Ils finissent",
"25-1.Nous finissons",
"25-1.Vous finissez",
"25-2.Je finirai",
"25-2.Tu finiras",
"25-2.Il finira",
"25-2.Ils finiront",
"25-2.Nous finirons",
"25-2.Vous finirez",
"25-3.Je finissais",
"25-3.Tu finissais",
"25-3.Il finissait",
"25-3.Ils finissaient",
"25-3.Nous finissions",
"25-3.Vous finissiez",
"25-4.Je finis",
"25-4.Tu finis",
"25-4.Il finit",
"25-4.Ils finirent",
"25-4.Nous finîmes",
"25-4.Vous finîtes",
"25-5.Je finisse",
"25-5.Tu finisses",
"25-5.Il finisse",
"25-5.Ils finissent",
"25-5.Nous finissions",
"25-5.Vous finissiez",
"25-6.Je finisse",
"25-6.Tu finisses",
"25-6.Il finît",
"25-6.Ils finissent",
"25-6.Nous finissions",
"25-6.Vous finissiez",
"25-7.Je finirais",
"25-7.Tu finirais",
"25-7.Il finirait",
"25-7.Ils finiraient",
"25-7.Nous finirions",
"25-7.Vous finiriez",
"25-8.Tu finis",
"25-8.Nous finissions",
"25-8.Vous finissiez",
"25-9.finissant ",
"25-10.fini(s) ",
"25-10.finie(s) ",
"25-11.J' ai",
"25-11.Tu as",
"25-11.Il a",
"25-11.Ils ont",
"25-11.Nous avons",
"25-11.Vous avez",
"25-12.J' aurai",
"25-12.Tu auras",
"25-12.Il aura",
"25-12.Ils auront",
"25-12.Nous aurons",
"25-12.Vous aurez",
"25-13.J' avais",
"25-13.Tu avais",
"25-13.Il avait",
"25-13.Ils avaient",
"25-13.Nous avions",
"25-13.Vous aviez",
"25-14.J' eus",
"25-14.Tu eus",
"25-14.Il eut",
"25-14.Ils eurent",
"25-14.Nous eûmes",
"25-14.Vous eûtes",
"25-15.J' aie",
"25-15.Tu aies",
"25-15.Il ait",
"25-15.Ils aient",
"25-15.Nous ayons",
"25-15.Vous ayez",
"25-16.J' eusse",
"25-16.Tu eusses",
"25-16.Il eût",
"25-16.Ils eussent",
"25-16.Nous eussions",
"25-16.Vous eussiez",
"25-17.J' aurais",
"25-17.Tu aurais",
"25-17.Il aurait",
"25-17.Ils auraient",
"25-17.Nous aurions",
"25-17.Vous auriez",
"25-18.J' eusse",
"25-18.Tu eusses",
"25-18.Il eût",
"25-18.Ils eussent",
"25-18.Nous eussions",
"25-18.Vous eussiez",
"25-19.Tu aie",
"25-19.Nous ayons",
"25-19.Vous ayez",
"70-1.Je pars",
"70-1.Tu pars",
"70-1.Il part",
"70-1.Ils partent",
"70-1.Nous partons",
"70-1.Vous partez",
"70-2.Je partirai",
"70-2.Tu partiras",
"70-2.Il partira",
"70-2.Ils partiront",
"70-2.Nous partirons",
"70-2.Vous partirez",
"70-3.Je partais",
"70-3.Tu partais",
"70-3.Il partait",
"70-3.Ils partaient",
"70-3.Nous partions",
"70-3.Vous partiez",
"70-4.Je partis",
"70-4.Tu partis",
"70-4.Il partit",
"70-4.Ils partirent",
"70-4.Nous partîmes",
"70-4.Vous partîtes",
"70-5.Je parte",
"70-5.Tu partes",
"70-5.Il parte",
"70-5.Ils partent",
"70-5.Nous partions",
"70-5.Vous partiez",
"70-6.Je partisse",
"70-6.Tu partisses",
"70-6.Il partît",
"70-6.Ils partissent",
"70-6.Nous partissions",
"70-6.Vous partissiez",
"70-7.Je partirais",
"70-7.Tu partirais",
"70-7.Il partirait",
"70-7.Ils partiraient",
"70-7.Nous partirions",
"70-7.Vous partiriez",
"70-8.Tu pars",
"70-8.Nous partons",
"70-8.Vous partez",
"70-9.partant ",
"70-10.parti(s) ",
"70-10.partie(s) ",
"70-11.Je suis",
"70-11.Tu es",
"70-11.Il est",
"70-11.Ils sont",
"70-11.Nous sommes",
"70-11.Vous êtes",
"70-12.Je serai",
"70-12.Tu seras",
"70-12.Il sera",
"70-12.Ils seront",
"70-12.Nous serons",
"70-12.Vous serez",
"70-13.J' étais",
"70-13.Tu étais",
"70-13.Il était",
"70-13.Ils étaient",
"70-13.Nous étions",
"70-13.Vous étiez",
"70-14.Je fus",
"70-14.Tu fus",
"70-14.Il fut",
"70-14.Ils furent",
"70-14.Nous fûmes",
"70-14.Vous fûtes",
"70-15.Je sois",
"70-15.Tu sois",
"70-15.Il soit",
"70-15.Ils soient",
"70-15.Nous soyons",
"70-15.Vous soyez",
"70-16.Je fusse",
"70-16.Tu fusses",
"70-16.Il fût",
"70-16.Ils fussent",
"70-16.Nous fussions",
"70-16.Vous fussiez",
"70-17.Je serais",
"70-17.Tu serais",
"70-17.Il serait",
"70-17.Ils seraient",
"70-17.Nous serions",
"70-17.Vous seriez",
"70-18.Je fusse",
"70-18.Tu fusses",
"70-18.Il fût",
"70-18.Ils fussent",
"70-18.Nous fussions",
"70-18.Vous fussiez",
"70-19.Tu sois",
"70-19.Nous soyons",
"70-19.Vous soyez",
"77-1.Je prends",
"77-1.Tu prends",
"77-1.Il prend",
"77-1.Ils prennent",
"77-1.Nous prenons",
"77-1.Vous prenez",
"77-2.Je prendrai",
"77-2.Tu prendras",
"77-2.Il prendra",
"77-2.Ils prendront",
"77-2.Nous prendrons",
"77-2.Vous prendrez",
"77-3.Je prenais",
"77-3.Tu prenais",
"77-3.Il prenait",
"77-3.Ils prenaient",
"77-3.Nous prenions",
"77-3.Vous preniez",
"77-4.Je pris",
"77-4.Tu pris",
"77-4.Il prit",
"77-4.Ils prirent",
"77-4.Nous prîmes",
"77-4.Vous prîtes",
"77-5.Je prenne",
"77-5.Tu prennes",
"77-5.Il prenne",
"77-5.Ils prennent",
"77-5.Nous prenions",
"77-5.Vous preniez",
"77-6.Je prisse",
"77-6.Tu prisses",
"77-6.Il prît",
"77-6.Ils prissent",
"77-6.Nous prissions",
"77-6.Vous prissiez",
"77-7.Je prendrais",
"77-7.Tu prendrais",
"77-7.Il prendrait",
"77-7.Ils prendraient",
"77-7.Nous prendrions",
"77-7.Vous prendriez",
"77-8.Tu prends",
"77-8.Nous prenons",
"77-8.Vous prenez",
"77-9.prenant ",
"77-10.pris ",
"77-10.prise(s) ",
"77-11.J' ai",
"77-11.Tu as",
"77-11.Il a",
"77-11.Ils ont",
"77-11.Nous avons",
"77-11.Vous avez",
"77-12.J' aurai",
"77-12.Tu auras",
"77-12.Il aura",
"77-12.Ils auront",
"77-12.Nous aurons",
"77-12.Vous aurez",
"77-13.J' avais",
"77-13.Tu avais",
"77-13.Il avait",
"77-13.Ils avaient",
"77-13.Nous avions",
"77-13.Vous aviez",
"77-14.J' eus",
"77-14.Tu eus",
"77-14.Il eut",
"77-14.Ils eurent",
"77-14.Nous eûmes",
"77-14.Vous eûtes",
"77-15.J' aie",
"77-15.Tu aies",
"77-15.Il ait",
"77-15.Ils aient",
"77-15.Nous ayons",
"77-15.Vous ayez",
"77-16.J' eusse",
"77-16.Tu eusses",
"77-16.Il eût",
"77-16.Ils eussent",
"77-16.Nous eussions",
"77-16.Vous eussiez",
"77-17.J' aurais",
"77-17.Tu aurais",
"77-17.Il aurait",
"77-17.Ils auraient",
"77-17.Nous aurions",
"77-17.Vous auriez",
"77-18.J' eusse",
"77-18.Tu eusses",
"77-18.Il eût",
"77-18.Ils eussent",
"77-18.Nous eussions",
"77-18.Vous eussiez",
"77-19.Tu aie",
"77-19.Nous ayons",
"77-19.Vous ayez",
"77-22. ",
"77-23. ",
"81-1.Je sais",
"81-1.Tu sais",
"81-1.Il sait",
"81-1.Ils savent",
"81-1.Nous savons",
"81-1.Vous savez",
"81-2.Je saurai",
"81-2.Tu sauras",
"81-2.Il saura",
"81-2.Ils sauront",
"81-2.Nous saurons",
"81-2.Vous saurez",
"81-3.Je savais",
"81-3.Tu savais",
"81-3.Il savait",
"81-3.Ils savaient",
"81-3.Nous savions",
"81-3.Vous saviez",
"81-4.Je sus",
"81-4.Tu sus",
"81-4.Il sut",
"81-4.Ils surent",
"81-4.Nous sûmes",
"81-4.Vous sûtes",
"81-5.Je sache",
"81-5.Tu saches",
"81-5.Il sache",
"81-5.Ils sachent",
"81-5.Nous sachions",
"81-5.Vous sachiez",
"81-6.Je susse",
"81-6.Tu susses",
"81-6.Il sût",
"81-6.Ils sussent",
"81-6.Nous sussions",
"81-6.Vous sussiez",
"81-7.Je saurais",
"81-7.Tu saurais",
"81-7.Il saurait",
"81-7.Ils sauraient",
"81-7.Nous saurions",
"81-7.Vous sauriez",
"81-8.Tu sache",
"81-8.Nous sachons",
"81-8.Vous sachez",
"81-9.sachant ",
"81-10.su(s) ",
"81-10.sue(s) ",
"81-11.J' ai",
"81-11.Tu as",
"81-11.Il a",
"81-11.Ils ont",
"81-11.Nous avons",
"81-11.Vous avez",
"81-12.J' aurai",
"81-12.Tu auras",
"81-12.Il aura",
"81-12.Ils auront",
"81-12.Nous aurons",
"81-12.Vous aurez",
"81-13.J' avais",
"81-13.Tu avais",
"81-13.Il avait",
"81-13.Ils avaient",
"81-13.Nous avions",
"81-13.Vous aviez",
"81-14.J' eus",
"81-14.Tu eus",
"81-14.Il eut",
"81-14.Ils eurent",
"81-14.Nous eûmes",
"81-14.Vous eûtes",
"81-15.J' aie",
"81-15.Tu aies",
"81-15.Il ait",
"81-15.Ils aient",
"81-15.Nous ayons",
"81-15.Vous ayez",
"81-16.J' eusse",
"81-16.Tu eusses",
"81-16.Il eût",
"81-16.Ils eussent",
"81-16.Nous eussions",
"81-16.Vous eussiez",
"81-17.J' aurais",
"81-17.Tu aurais",
"81-17.Il aurait",
"81-17.Ils auraient",
"81-17.Nous aurions",
"81-17.Vous auriez",
"81-18.J' eusse",
"81-18.Tu eusses",
"81-18.Il eût",
"81-18.Ils eussent",
"81-18.Nous eussions",
"81-18.Vous eussiez",
"81-19.Tu aie",
"81-19.Nous ayons",
"81-19.Vous ayez"]

  @State var answer = [String](repeating: "", count: 99)
  @State var selectedAnswer = 0
  
  @State var blanks = [String](repeating: "", count: 99)
  @State var display0 = false
  @State var display1 = false
  @State var display2 = false
  @State var showColor = false
  @State var verbID:Int!
  @State var tenseID:Int!
  
  @State var lvalue:Int = 99
  @State var pvalue:Int = 99

  var body: some View {
    
    return VStack(alignment: .center) {
      
//      List {
//        ForEach(verb, id: \.self) { each in
//          HStack {
//            Spacer()
//            Text(each)
//            Spacer()
//          }
//        }
//      }.onTapGesture {
//        for instance in self.verbs {
//          self.verb.append(instance.value)
//        }
//      }
//      .font(Fonts.avenirNextCondensedBold(size: 16))
//      .frame(width: 256, height: 128, alignment: .center)
      if display0 {
      Picker("", selection: $selectedTense) {
        ForEach((0 ..< tensey.tensex.count), id: \.self) { column in
//        ForEach(0 ..< tenses.count) {
          Text(self.tensey.tensex[column].name)
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .background(self.showColor ? Color.yellow: Color.clear)
        }
      }.labelsHidden()
      .frame(width: 256, height: 128, alignment: .center)
      .onReceive([selectedTense].publisher) { ( value ) in
        self.tenseID = self.tensey.tensex[value].id
        if value != self.lvalue {
          self.display2 = false
          var count = 0
          self.answer.removeAll()
          for instance in self.answery.answerx {
            if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
              self.answer.append(instance.name)
              print("self.answer ",instance)
              count += 1
            }
          }
          self.lvalue = value
          DispatchQueue.main.asyncAfter(deadline: .now() + Double(1)) {
            self.display2 = true
          }
        }
      }
      } else {
        Picker("", selection: $selectedAnswer) {
        ForEach(0 ..< blanks.count) {
          Text(self.blanks[$0])
          .font(Fonts.avenirNextCondensedBold(size: 16))
        }
        }.labelsHidden()
        .frame(width: 256, height: 128, alignment: .center)
      }
      Spacer().frame(height: 64)
     
      if display1 {
      Picker("", selection: $selectedVerb) {
        ForEach((0 ..< verby.verbx.count), id: \.self) { column in
//        ForEach(0 ..< verb.count) {
          Text(self.verby.verbx[column].name)
          .font(Fonts.avenirNextCondensedBold(size: 16))
          }
        }.onReceive([selectedVerb].publisher.first()) { ( value ) in
          self.verbID = self.verby.verbx[value].id
          if shaker {
          if value != self.pvalue {
          self.display2 = false
          var count = 0
          self.answer.removeAll()
          for instance in self.answery.answerx {
            if instance.tenseID == self.tenseID && instance.verbID == self.verbID {
              self.answer.append(instance.name)
              print("self.answer ",instance)
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
        .frame(width: 256, height: 128, alignment: .center)
        
       
      } else {
        Picker("", selection: $selectedAnswer) {
        ForEach(0 ..< blanks.count) {
          Text(self.blanks[$0])
          .font(Fonts.avenirNextCondensedBold(size: 16))
        }
        }.labelsHidden()
        .frame(width: 256, height: 128, alignment: .center)
      }
      Spacer().frame(height: 64)
      if display2 {
        Picker("", selection: $selectedAnswer) {
        ForEach(0 ..< answer.count) {
//        ForEach((0 ..< self.answery.answerx.count), id: \.self) { column in
          
            TextView(textValue: self.answer[$0])
//            Text(self.answer[column]).background(Color.yellow)
            .font(Fonts.avenirNextCondensedBold(size: 16))
          
        }
        }.labelsHidden()
        .frame(width: 256, height: 128, alignment: .center)
        
      } else {
        Picker("", selection: $selectedAnswer) {
        ForEach(0 ..< blanks.count) {
            Text(self.blanks[$0])
            .font(Fonts.avenirNextCondensedBold(size: 16))
        }
        }.labelsHidden()
        .frame(width: 256, height: 128, alignment: .center)
      }
//      Spacer().frame(height: 10)
      
      
      //         Text("You selected: \(tenses[selectedTense])")
      
//    List {
//        ForEach(answer, id: \.self) { each in
//          HStack {
//            Spacer()
//            Text(each)
//            .font(Fonts.avenirNextCondensedBold(size: 16))
//            Spacer()
//          }
//        }
//      }
//      .frame(width: 256, height: 128, alignment: .center)
//      .onTapGesture {
//        for instance in self.answers {
//          self.answer.append(instance.value)
//        }
//      }
    }.onReceive(populatePublisher, perform: { (_) in
        for instance in self.verbs {
//          self.verb.append(instance.value)
          let newVerb = verbBlob(id: instance.key, name: instance.value)
          self.verby.verbx.append(newVerb)
        }
        for instance in self.tenses {
//          self.verb.append(instance.value)
          let newTense = tenseBlob(id: instance.key, name: instance.value)
          self.tensey.tensex.append(newTense)
        }
        for instance in self.answers {
//          self.verb.append(instance.value)
          
          let byteA = instance.components(separatedBy: ".")
          let byteB = byteA[0].components(separatedBy: "-").map({Int($0)})
          let newAnswer = answerBlob(verbID: byteB[0], tenseID: byteB[1], name: byteA[1])
          self.answery.answerx.append(newAnswer)
          print("inst ",instance,"X",byteA[1])
        }
        
        self.display0 = true
        self.display1 = true
        self.display2 = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(4)) {
            shaker = true
          }
        
      })
  }
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
      populatePublisher.send()
    }
  }
}
