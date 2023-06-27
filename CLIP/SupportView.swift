//
//  SupportView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//
import SwiftUI
import WebKit

struct SupportView: View {
    var body: some View {
        WebView(url: URL(string: "https://clip.bike")!)
            .navigationBarTitle("Support", displayMode: .inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
