//
//  JointPurchasesPayJointPurchasesPayRouter.swift
//  SBOLN-IOS
//
//  Created by Denis on 25/09/2017.
//  Copyright © 2017 Example. All rights reserved.
//

protocol JointPurchasesPayRouterProtocol: BaseRouterProtocol {
    func showSelectCard(module: ChooseItemModule<SelectCardModel>)
    func showSuccessActionScreen(with action: ActionBaseContractType, creditCard: CreditCardObject?, amount: Double, requestId: String?)
}

class JointPurchasesPayRouter: BaseRouter, JointPurchasesPayRouterProtocol {
    func showSelectCard(module: ChooseItemModule<SelectCardModel>) {
        self.transitionHandler.presentOnSelf(module: module, animated: true)
    }
    
    func showSuccessActionScreen(with action: ActionBaseContractType, creditCard: CreditCardObject?, amount: Double, requestId: String?) {
        let module = StatusActionContractModule.assembly()
        module.input.configure(with: action, creditCard: creditCard, amount: amount, requestId: requestId, check: String.empty)
        
        self.transitionHandler.presentFromSelf(module: module, animated: true)
    }
    
}
