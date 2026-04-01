//
//  SavedArticleScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI

struct SavedArticleScreen: View {

//    let savedArticles: [Article] = [
//        Article(
//            headline: "Joby Aviation Partners with Delta and Uber to Create Air Taxis",
//            category: "Tech",
//            imageName: "airplane",
//            isFeature: false
//        ),
//        Article(
//            headline: "Former OpenAI CTO Launches Thinking Machines Lab",
//            category: "AI",
//            imageName: "person.crop.circle",
//            isFeature: false
//        ),
//        Article(
//            headline: "DoorDash is buying Deliveroo for about $3.9 billion",
//            category: "Business",
//            imageName: "creditcard.fill",
//            isFeature: false
//        ),
//        Article(
//            headline: "Mark Cuban Leaves Shark Tank After Season 16",
//            category: "Entertainment",
//            imageName: "person.fill",
//            isFeature: false
//        ),
//        Article(
//            headline: "Neuralink Raises $650 Series E Round",
//            category: "Tech",
//            imageName: "bolt.fill",
//            isFeature: false
//        )
//    ]
    
    var body: some View {
        VStack(spacing: 0) {

            // Top Nav
            Layman_NavBar(title: "Saved", hideSearch: false)

            // List
            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(savedArticles) { article in
//                        ArticleRow(article: article)
//                    }
//                }
//                .padding(.top, 4)
//                .padding(.bottom, 20)
            }
        }
        .background(Color.viewBackground.ignoresSafeArea())
    }
}
