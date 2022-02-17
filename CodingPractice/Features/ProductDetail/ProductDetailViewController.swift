import UIKit

final class ProductDetailViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textColor = .darkText
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return label
    }()
    
    private lazy var descriptionLabal: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .gray
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Favorite", for: .normal)
        button.setTitleColor(.darkText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Product Details"
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.text = "Big Title"
        
        self.view.addSubview(self.descriptionLabal)
        self.descriptionLabal.text = """
        A wiki (/ˈwɪki/ (audio speaker iconlisten) WIK-ee) is a hypertext publication collaboratively edited and managed by its own audience directly using a web browser. A typical wiki contains multiple pages for the subjects or scope of the project and could be either open to the public or limited to use within an organization for maintaining its internal knowledge base.
        """
        
        self.view.addSubview(self.favoriteButton)
        
        let layoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 18),
            self.titleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 18),
            self.titleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -18),
            self.descriptionLabal.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 18),
            self.descriptionLabal.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.descriptionLabal.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.favoriteButton.topAnchor.constraint(equalTo: self.descriptionLabal.bottomAnchor, constant: 18),
            self.favoriteButton.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.favoriteButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.favoriteButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -18)
        ])
    }
}
