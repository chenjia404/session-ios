// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import SessionUtilitiesKit
class SettingAddressCell: BaseTableViewCell {
    private let labAddress = UILabel(font: UIFont.systemFont(ofSize: Values.largeFontSize),textColor: .textPrimary)
    override func layoutUI() {
        self.contentView.addSubview(cellBackgroundView)
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: Values.verySmallSpacing, left: Values.largeSpacing, bottom: Values.largeSpacing, right: Values.largeSpacing))
        }
        
        labAddress.numberOfLines = 0
        cellBackgroundView.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: Values.mediumSpacing, left: Values.mediumSpacing, bottom: Values.veryLargeSpacing, right: Values.mediumSpacing))
        }
        
        let btnCopy = UIButton(title: "copy".localized(),font: .systemFont(ofSize: Values.mediumFontSize),color: .sessionButton_text)
        btnCopy.addTarget(self, action: #selector(onclickCopy), for: .touchUpInside)
        cellBackgroundView.addSubview(btnCopy)
        btnCopy.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 80.w, height: 40.w))
        }
    }
    
    private let cellBackgroundView: UIView = {
        let result: UIView = UIView(.settings_tabBackground)
        result.dealLayer(corner: 17)
        result.themeBackgroundColor = .settings_tabBackground
        return result
    }()

    @objc func onclickCopy(){
        UIPasteboard.general.string = self.address
        Toast.toast(hit: "copied".localized())
    }
    
    public var address : String?{
        didSet{
            labAddress.text = address
        }
    }
    
}
