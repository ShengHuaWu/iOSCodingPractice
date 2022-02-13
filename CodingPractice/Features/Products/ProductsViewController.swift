import UIKit

final class ProductsViewController: UITableViewController {
    private enum Constants {
        static let productCellId = "ProductCell"
    }
    
    private let viewModel: ProductsViewModel
    
    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Products"
        self.view.backgroundColor = .white
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.productCellId)
        
        self.viewModel.register { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.getProducts()
    }
}

// MARK: - UITableViewDataSource

extension ProductsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfProducts()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.productCellId, for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
}