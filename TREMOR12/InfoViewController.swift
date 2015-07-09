//
//  InfoViewController.swift
//  TremorDBS
//
//  Created by Pieter Kubben on 29-05-15.
//  Copyright (c) 2015 DigitalNeurosurgeon.com. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfoContentInWebview(infoWebView)
    }

    func loadInfoContentInWebview(webView: UIWebView) {
        let infoHTMLString = "<body style=\"font-family: Arial; \"> " +
            
            "<h3>Maastricht DBS team</h3>" +
            "<ul>" +
                "<li>Prof. Yasin Temel, MD, PhD</li>" +
                "<li>Linda Ackermans, MD, PhD</li>" +
                "<li>Pieter Kubben, MD, PhD</li>" +
                "<li>Mark Kuijf, MD, PhD</li>" +
                "<li>Maayke Oosterloo, MD, PhD</li>" +
                "<li>Albert Leentjens, MD, PhD</li>" +
                "<li>Annelien Duits, PhD</li>" +
                "<li>Nicole Bakker</li>" +
                // "<li></li>" +
            "</ul>" +
            
            "<h3>Design &amp; development</h3>" +
            "<ul>" +
                "<li>Pieter Kubben, MD, PhD</li>" +
            "</ul>" +
            
            "<h3>Contact</h3>" +
            "<ul>" +
                "<li><a style=\"color: #800000;\" href=\"http://dign.eu\">Website</a></li><br/>" +
                "<li><a style=\"color: #800000;\" href=\"mailto:pieter@kubben.nl\">Email</a></li><br/>" +
                "<li><a style=\"color: #800000;\" href=\"http://twitter.com/DigNeurosurgeon\">Twitter</a></li><br/>" +
            "</ul>" +
            
        "</body>"
        
        webView.loadHTMLString(infoHTMLString, baseURL: nil)
    }

}
