import UIKit

final class ProductsViewController: UITableViewController {
    private enum Constants {
        static let productCellId = "ProductCell"
    }
    
    private let viewModel: ProductsViewModel
    private var productRows: [ProductRowDisplayInfo] = []
    
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
                    
                case let .loaded(rows):
                    strongSelf.productRows = rows
                    strongSelf.tableView.reloadData()
                    
                case let .update(id, isFavorited):
                    guard let row = strongSelf.productRows.firstIndex(where: { $0.id == id }) else {
                        return
                        
                    }
                    
                    let displayInfo = strongSelf.productRows.remove(at: row)
                    let newDisplayInfo = ProductRowDisplayInfo(
                        id: id,
                        title: displayInfo.title,
                        isFavorited: isFavorited
                    )
                    strongSelf.productRows.insert(newDisplayInfo, at: row)
                    
                    let indexPath = IndexPath(row: row, section: 0)
                    guard let visibleRows = strongSelf.tableView.indexPathsForVisibleRows,
                       visibleRows.contains(indexPath) else {
                        return
                    }
                    
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
        return self.productRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.productCellId, for: indexPath)
        self.configure(cell, at: indexPath.row)
        
        return cell
    }
    
    private func configure(_ cell: UITableViewCell, at index: Int) {
        let displayInfo = self.productRows[index]
        
        cell.textLabel?.text = displayInfo.title
        
        let isFavorited = displayInfo.isFavorited
        cell.detailTextLabel?.textColor = isFavorited ? .red : .darkGray
        cell.detailTextLabel?.text = isFavorited ? "favorited" : "not favorited"
    }
}

// MARK: - UITableViewDelegate

extension ProductsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.presentProductDetail(with: self.productRows[indexPath.row].id)
    }
}
