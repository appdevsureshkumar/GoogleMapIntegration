import UIKit

final class DetailsViewController: UIViewController {
    private let address: String
    private let airQuality: Int
    private let maxNicknameLength = 20

    private let addressLabel = UILabel()
    private let airQualityLabel = UILabel()
    private let nickNameTextField = UITextField()
    private let nickNameUpdateButton = UIButton()
    private let nickNameSkipButton = UIButton()
    public var completionNickName: ((String?) -> Void)? = nil

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
        
        nickNameTextField.translatesAutoresizingMaskIntoConstraints = false
        nickNameTextField.placeholder = "nickname"
        nickNameTextField.borderStyle = .roundedRect
        nickNameTextField.delegate = self
        
        nickNameUpdateButton.setTitle("Update", for: .normal)
        nickNameUpdateButton.setTitleColor(.white, for: .normal)
        nickNameUpdateButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        nickNameUpdateButton.layer.cornerRadius = 10
        nickNameUpdateButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        nickNameUpdateButton.addTarget(self, action: #selector(updateNickName), for: .touchUpInside)

        nickNameSkipButton.setTitle("Skip", for: .normal)
        nickNameSkipButton.setTitleColor(.white, for: .normal)
        nickNameSkipButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.9)
        nickNameSkipButton.layer.cornerRadius = 10
        nickNameSkipButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        nickNameSkipButton.addTarget(self, action: #selector(skipNickName), for: .touchUpInside)

        let vstack = UIStackView(arrangedSubviews: [nickNameTextField, nickNameUpdateButton, nickNameSkipButton])
        vstack.translatesAutoresizingMaskIntoConstraints = false
        vstack.axis = .vertical
        vstack.spacing = 10
        vstack.alignment = .center
        vstack.distribution = .fill
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vstack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func updateNickName() {
        let trimmed = nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let capped = String(trimmed.prefix(maxNicknameLength))
        completionNickName?(capped.isEmpty ? nil : capped)
        navigationController?.popViewController(animated: true)
    }

    @objc private func skipNickName() {
        completionNickName?(nil)
        navigationController?.popViewController(animated: true)
    }
}
extension DetailsViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        let updatedText = current.replacingCharacters(in: textRange, with: string)
        return updatedText.count <= maxNicknameLength
    }
}

