// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUtilitiesKit
import SnapKit
public class InputModal: Modal {
    var confirmAction : ((String)->())?
    
    
    public init(targetView: UIView? = nil, title: String,content: String) {
        super.init(targetView: targetView, dismissType: .recursive, afterClosed: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.titleLabel.text = title
        self.explanationLabel.text = content
    }
    
    @discardableResult
    public func confirmAction(_ action: @escaping (String) -> Void) -> InputModal {
        confirmAction = action
        return self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Components
    
    private let titleLabel: UILabel = {
        let result: UILabel = UILabel()
        result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
        result.themeTextColor = .textPrimary
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    private let explanationLabel: UILabel = {
        let result: UILabel = UILabel()
        result.font = .systemFont(ofSize: Values.smallFontSize)
        result.themeTextColor = .textPrimary
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    private lazy var textInput: UITextField = {
        let result = UITextField("LocalPleaseInput".localized(),font: Fonts.spaceMono(ofSize: Values.smallFontSize),textColor: ThemeValue.textPrimary)
        result.addLeftView(30.w)
        result.dealBorderLayer(corner: TextField.cornerRadius, bordercolor: .textPrimary, borderwidth: 1)
        return result
    }()
    
    
    private lazy var copyButton: UIButton = {
        let result: UIButton = Modal.createButton(
            title: "LocalConfirm".localized(),
            titleColor: ThemeValue.textPrimary
        )
        result.addTarget(self, action: #selector(copySeed), for: .touchUpInside)
        
        return result
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ copyButton, cancelButton ])
        result.axis = .horizontal
        result.spacing = Values.mediumSpacing
        result.distribution = .fillEqually
        
        return result
    }()
    
    private lazy var contentStackView: UIView = {
        let result = UIView()
        result.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Values.largeSpacing)
        }
        
        result.addSubview(explanationLabel)
        explanationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Values.largeSpacing)
            make.right.equalToSuperview().offset(-Values.largeSpacing)
            make.top.equalTo(titleLabel.snp.bottom).offset(Values.smallSpacing)
        }
        
        result.addSubview(textInput)
        textInput.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Values.largeSpacing)
            make.right.equalToSuperview().offset(-Values.largeSpacing)
            make.top.equalTo(explanationLabel.snp.bottom).offset(Values.smallSpacing)
            make.height.equalTo(40.w)
            make.bottom.equalToSuperview().offset(Values.verySmallSpacing)
        }
        
//        let result = UIStackView(arrangedSubviews: [ titleLabel, explanationLabel, textInput ])
//        result.axis = .vertical
//        result.spacing = Values.smallSpacing
//        result.isLayoutMarginsRelativeArrangement = true
//        result.layoutMargins = UIEdgeInsets(
//            top: Values.largeSpacing,
//            left: Values.largeSpacing,
//            bottom: Values.verySmallSpacing,
//            right: Values.largeSpacing
//        )
        return result
    }()
    
    private lazy var mainStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ contentStackView, buttonStackView ])
        result.axis = .vertical
        result.spacing = Values.largeSpacing - Values.smallFontSize / 2
        
        return result
    }()
    
    // MARK: - Lifecycle
    
    public override func populateContentView() {
        contentView.addSubview(mainStackView)
        
        mainStackView.pin(to: contentView)
        
    }
    
    // MARK: - Interaction
    
    @objc private func copySeed() {
        guard let value = self.textInput.text, value.removeSpace() != "" else{
            return
        }
        
        self.confirmAction?(value)
        dismiss(animated: true, completion: nil)
    }
}
