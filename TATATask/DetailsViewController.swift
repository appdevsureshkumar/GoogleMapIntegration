import UIKit

final class DetailsViewController: UIViewController {
    private let address: String
    private let airQuality: Int

    private let addressLabel = UILabel()
    private let airQualityLabel = UILabel()

    init(address: String, airQuality: Int) {
        self.address = address
        self.airQuality = airQuality
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Details"

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = address
        addressLabel.textAlignment = .center
        addressLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        addressLabel.numberOfLines = 0

        airQualityLabel.translatesAutoresizingMaskIntoConstraints = false
        airQualityLabel.text = "AQI \(airQuality)"
        airQualityLabel.textAlignment = .center
        airQualityLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)

        let stackView = UIStackView(arrangedSubviews: [addressLabel, airQualityLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
