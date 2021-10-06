//
//  CustomTweetView.swift
//  TUV
//
//  Created by Khalil Kum on 9/25/21.
//

import UIKit

@IBDesignable
class CustomTweetView: UIView {
    let nibName = "CustomTweetView"
    var contentView: UIView?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var tweetMetricsStackView: UIStackView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var repliesCountLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
