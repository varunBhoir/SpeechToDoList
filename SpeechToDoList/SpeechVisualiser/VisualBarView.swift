//
//  VisualBarView.swift
//  SpeechToDoList
//
//  Created by varun bhoir on 19/03/21.
//

import SwiftUI

struct VisualBarView: View {
    let noOfSamples = 30
    var value: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom))
            .frame(width: (UIScreen.main.bounds.width - CGFloat(noOfSamples) * 10) / CGFloat(noOfSamples), height: value)
    }
}

struct VisualBarView_Previews: PreviewProvider {
    static var previews: some View {
        VisualBarView(value: 100)
    }
}
