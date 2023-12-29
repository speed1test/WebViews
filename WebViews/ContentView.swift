//
//  ContentView.swift
//  WebViews
//
//  Created by elsalvador on 29/12/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    @Binding var pageTitle: String
    @Binding var canGoBack: Bool
    @Binding var previousURL: String?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url?.absoluteString != urlString {
            let url = URL(string: urlString)!
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.pageTitle = webView.title ?? ""
            parent.urlString = webView.url?.absoluteString ?? ""
            parent.canGoBack = webView.canGoBack

            if let previousURL = webView.backForwardList.backItem?.url.absoluteString {
                parent.previousURL = previousURL
            } else {
                parent.previousURL = nil
            }
        }
    }
}

struct ContentView: View {
    @State private var pageTitle: String = ""
    @State private var urlString: String = "https://www.google.com"
    @State private var canGoBack: Bool = false
    @State private var previousURL: String?

    var truncatedURL: String {
        let maxLength = 30
        return urlString.count > maxLength ? String(urlString.prefix(maxLength)) + "..." : urlString
    }

    var body: some View {
        NavigationView {
            VStack {
                WebView(urlString: $urlString, pageTitle: $pageTitle, canGoBack: $canGoBack, previousURL: $previousURL)
                    .navigationBarTitle(pageTitle, displayMode: .inline)

                Spacer()

                HStack {
                    Button(action: {
                        // Navegar hacia atrás
                        if let previousURL = previousURL {
                            urlString = previousURL
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .padding()
                    }

                    Spacer()

                    Text(truncatedURL)
                        .padding()

                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

#Preview {
    ContentView()
}
