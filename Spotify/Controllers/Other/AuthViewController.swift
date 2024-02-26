//
//  AuthViewController.swift
//  Spotify
//
//  Created by Tanvir Alam on 24/2/24.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {

    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webview = WKWebView(frame: .zero, configuration: config)
        return webview
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInUrl else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {return}
        guard let code = URLComponents(string: url.absoluteString)?
            .queryItems?
            .first(where: {$0.name == "code"})?
            .value else {return}
        print("CODE: \(code)")
        AuthManager.shared.exchangeCodeForTokens(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
