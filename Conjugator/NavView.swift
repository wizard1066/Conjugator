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
            Text("Conjugator")
              .font(Fonts.avenirNextCondensedBold(size: 32))
              .padding()

            navlink
            .frame(width:0, height:0)

            Button("Hard") {
                self.env.level = "hard"
                self.env.currentPage = .SecondPage
            }
              .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
              .border(Color.primary)
              .font(Fonts.avenirNextCondensedBold(size: 20))
            Spacer()
              .frame(width: 1, height: 10, alignment: .center)
            Button("Medium") {
                self.env.level = "medium"
                self.env.currentPage = .SecondPage
            }
              .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
              .border(Color.primary)
              .font(Fonts.avenirNextCondensedBold(size: 20))
            Spacer()
              .frame(width: 1, height: 10, alignment: .center)
            Button("Easy") {
                self.env.level = "easy"
                self.env.currentPage = .SecondPage
            }
              .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
              .border(Color.primary)
              .font(Fonts.avenirNextCondensedBold(size: 20))

        }
    }

}


//struct PageTwo: View {
//
//    @EnvironmentObject var env : MyAppEnvironmentData
//
//    var body: some View {
//        VStack {
//            Text("Page Two").font(.largeTitle).padding()
//
//            Text("Go Back")
//            .padding()
//            .border(Color.primary)
//            .onTapGesture {
//                self.env.currentPage = .Menu
//            }
//        }.navigationBarBackButtonHidden(true)
//    }
//}

#if DEBUG
struct NavigationTest_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTest().environmentObject(MyAppEnvironmentData())
    }
}
#endif
