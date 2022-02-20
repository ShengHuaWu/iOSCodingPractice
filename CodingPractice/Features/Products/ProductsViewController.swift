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
        
        // Register custom cell type to show the detail text label
        self.tableView.register(ProductRowCell.self, forCellReuseIdentifier: Constants.productCellId)
        
        self.viewModel.onStateChange { [weak self] state in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    // TODO: Show loading indicator
                    break
                    
                case .loaded:
                    strongSelf.tableView.reloadData()
                    
                case let .update(row):
                    let indexPath = IndexPath(row: row, section: 0)
                    strongSelf.tableView.cellForRow(at: indexPath).map { cell in
                        strongSelf.configure(cell, at: row)
                    }
                    
                case .error:
                    // TODO: Show error alert
                    break
                }
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
        self.configure(cell, at: indexPath.row)
        
        return cell
    }
    
    private func configure(_ cell: UITableViewCell, at index: Int) {
        let displayInfo = self.viewModel.getProductRow(at: index)
        
        cell.textLabel?.text = displayInfo.title
        
        let isFavorited = displayInfo.isFavorited
        cell.detailTextLabel?.textColor = isFavorited ? .red : .darkGray
        cell.detailTextLabel?.text = isFavorited ? "favorited" : "not favorited"
    }
}

// MARK: - UITableViewDelegate

extension ProductsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.presentProductDetail(at: indexPath.row)
    }
}
