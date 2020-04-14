//
//  JointPurchasesPayJointPurchasesPayAssembly.swift
//  SBOLN-IOS
//
//  Created by Denis on 25/09/2017.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit


protocol JointPurchasesPayModuleInputProtocol: ModuleInputProtocol {

}

protocol JointPurchasesPayModuleOutputProtocol {

}

final class JointPurchasesPayModule: Module {

    private(set) var view: UIViewController
    private(set) var input: JointPurchasesPayModuleInputProtocol

    private init(view: JointPurchasesPayViewController, input: JointPurchasesPayModuleInputProtocol) {

	self.view = view
	self.input = input
    }

    static func assembly() ->  JointPurchasesPayModule{

        let router = JointPurchasesPayRouter()
        let presenter = JointPurchasesPayPresenter()
        let view = JointPurchasesPayViewController()
        let interactor = JointPurchasesPayInteractor(inputDatabaseService: DatabaseService.instance)

        view.output = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        router.transitionHandler = view
	
        let module = JointPurchasesPayModule(view: view, input: presenter)
        return module

    }
    
    static func assembly(model: JointPurchasesPayModel) ->  JointPurchasesPayModule{
        
        let router = JointPurchasesPayRouter()
        let presenter = JointPurchasesPayPresenter()
        let view = JointPurchasesPayViewController()
        let interactor = JointPurchasesPayInteractor(inputDatabaseService: DatabaseService.instance)

        view.output = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        presenter.model = model
        router.transitionHandler = view
        
        let module = JointPurchasesPayModule(view: view, input: presenter)
        return module
        
    }
 
}
