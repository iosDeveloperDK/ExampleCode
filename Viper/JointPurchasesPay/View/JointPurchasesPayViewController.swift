//
//  JointPurchasesPayJointPurchasesPayViewController.swift
//  SBOLN-IOS
//
//  Created by Denis on 25/09/2017.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit


protocol JointPurchasesPayViewInputProtocol: ProgressViewProtocol, DisplayErrorMessageProtocol, AlertPresenterProtocol {
    func setEnableMainButton(enable: Bool)

    func updateCreditCard()
    
    func reloadData()
}

protocol JointPurchasesPayViewOutputProtocol {
    var message: String? { get }
    var parameters: [Parameter] { get }
    var creditCard: CreditCardObject { get }
    var paymentPassword: String { get set }
    var amount: Double { get }
    var displayName: String? { get }
    func chooseNewCreditCard()
    func stateLoadingBalanceCreditCard() -> StateLoadingBalance
    func refreshBalanceCreditCard()
    func viewAppeared()
    func viewDisappeared()
    func viewDidLoad()
    func sendRequest()
}

class JointPurchasesPayViewController: BaseViewController, JointPurchasesPayViewInputProtocol {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet private weak var creditCardView: CreditCardView!
    @IBOutlet private weak var passwordInputTextView: InputTextView!
    @IBOutlet private weak var amountInputTextView: InputTextView!
    @IBOutlet private weak var messageInputTextView: InputTextView!
    @IBOutlet private weak var fromCardLabel: UILabel!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var displayNameTitleLabel: UILabel!

    @IBOutlet private var buttonView: ButtonView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet fileprivate weak var constraintHeightCreditCardView: NSLayoutConstraint!

    var output: JointPurchasesPayViewOutputProtocol!
    fileprivate lazy var doubleConverter = RoundedDoubleConverter()

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(nibName: InputTextTableViewCell.typeName, cellReuseIdentifier: InputTextTableViewCell.typeName)
        tableView.register(nibName: CellWithSwitch.typeName, cellReuseIdentifier: CellWithSwitch.cellId())
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.isHidden = true
        prepareView()
        self.output.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewAppeared()
        isHiddenNavigationBar = false
        updateCreditCard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewDisappeared()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateTableHeaderViewSize()
    }
    
    func updateCreditCard() {
        weak var weakSelf = self
        
        self.fromCardLabel.text = L10n.fromTheCard.string
        
        self.creditCardView.configure(creditCard: output.creditCard,
                                      state: output.stateLoadingBalanceCreditCard(),
                                      didSelectClosure: { (_) in
                                        weakSelf?.output.chooseNewCreditCard()
        }) {
            weakSelf?.output.refreshBalanceCreditCard()
        }
        
        updateTableHeaderViewSize()
    }
    
    func reloadData() {
        self.displayNameLabel.text = self.output.displayName
        self.displayNameTitleLabel.text = L10n.customerPhoneNumber.string
        self.tableView.isHidden = false

        let amountParameter = Parameter()
        amountParameter._DataType = DataType.Double
        amountParameter.__text = "\(doubleConverter.convert(output.amount) ?? String.empty) \(CurrencyCode.BYN_NAME)"
        amountParameter._Name = L10n.swiftThirdStepAmount.string
        amountParameter._Editable = BOOLShortString.N
        amountInputTextView.configureWithParameter(amountParameter)

        let messageParameter = Parameter()
        messageParameter.__text = output.message
        messageParameter._Name = L10n.jointPurchasesStartExecutorPlaceholder.string
        messageParameter._Editable = BOOLShortString.N
        messageInputTextView.configureWithParameter(messageParameter)
        
        passwordInputTextView.configurePassword("", placehoder:nil) { (password) in
            self.output.paymentPassword = password
        }

        self.tableView.reloadData()
        updateTableHeaderViewSize()
    }
    
    func setEnableMainButton(enable: Bool) {
        self.buttonView?.setEnbaled(enable)
    }
    
    private func updateTableHeaderViewSize() {
        if let headerView = tableView.tableHeaderView,
            let unwrappedConstraintHeightCreditCardView = constraintHeightCreditCardView {
            unwrappedConstraintHeightCreditCardView.isActive = false
            let heightCreditCard = creditCardView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            unwrappedConstraintHeightCreditCardView.isActive = true
            unwrappedConstraintHeightCreditCardView.constant = heightCreditCard
            creditCardView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    private func prepareView() {
        title = L10n.jointPurchasesPayTitle(doubleConverter.convert(self.output.amount) ?? String.empty).string
        buttonView.setEnbaled(false)
        buttonView.setTitle(title: L10n.send.string)
        buttonView.didSelectClosure = { [weak self] _ in
            if let unwrapSelf = self {
                unwrapSelf.output.sendRequest()
            }
        }
    }
}

extension JointPurchasesPayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.output.parameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let parameter = self.output.parameters[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        let dataType: DataType = parameter._DataType ?? DataType.String
        
        switch dataType {
        case .Bool:
            return cellWithSwitch(parameter: parameter)
        default:
            return inputTextTableViewCell(parameter: parameter)
        }
    }
    
    func cellWithSwitch(parameter: Parameter) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellWithSwitch.cellId()) as?  CellWithSwitch else {
            return UITableViewCell()
        }
        
        cell.configure(parameter: parameter)
        
        return cell
    }
    
    func inputTextTableViewCell(parameter: Parameter) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InputTextTableViewCell.typeName) as? InputTextTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureWithParameter(parameter)
        
        return cell
    }
    
}
