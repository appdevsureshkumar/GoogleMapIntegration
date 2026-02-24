import UIKit

final class DetailsViewController: UIViewController {
    private let address: String
    private let airQuality: Int
    private let slotTitle: String
    private let maxNicknameLength = 20

    private let slotLabel = UILabel()
    private let addressLabel = UILabel()
    private let airQualityTitleLabel = UILabel()
    private let airQualityValueLabel = UILabel()
    private let nickNameTextField = UITextField()
    private let nickNameUpdateButton = UIButton()
    public var completionNickName: ((String?) -> Void)? = nil

    init(address: String, airQuality: Int, slotTitle: String) {
        self.address = address
        self.airQuality = airQuality
        self.slotTitle = slotTitle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        slotLabel.translatesAutoresizingMaskIntoConstraints = false
        slotLabel.text = slotTitle
        slotLabel.textColor = .label
        slotLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = address
        addressLabel.textColor = .label
        addressLabel.textAlignment = .left
        addressLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        addressLabel.numberOfLines = 0

        airQualityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        airQualityTitleLabel.text = "aqi"
        airQualityTitleLabel.textColor = .black
        airQualityTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        airQualityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        airQualityValueLabel.text = "\(airQuality)"
        airQualityValueLabel.textColor = .label
        airQualityValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let titleStack = UIStackView(arrangedSubviews: [slotLabel, addressLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal
        titleStack.spacing = 12
        titleStack.alignment = .center

        let airStack = UIStackView(arrangedSubviews: [airQualityTitleLabel, airQualityValueLabel])
        airStack.translatesAutoresizingMaskIntoConstraints = false
        airStack.axis = .horizontal
        airStack.spacing = 15
        airStack.alignment = .center
       // airStack.distribution = .equalSpacing

        view.addSubview(titleStack)
        view.addSubview(airStack)

        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            airStack.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8),
            airStack.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            airStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        nickNameTextField.translatesAutoresizingMaskIntoConstraints = false
        nickNameTextField.placeholder = "nickname"
        nickNameTextField.borderStyle = .roundedRect
        nickNameTextField.delegate = self
        nickNameTextField.backgroundColor = .white
        
        nickNameUpdateButton.setTitle("V", for: .normal)
        nickNameUpdateButton.setTitleColor(.black, for: .normal)
        nickNameUpdateButton.backgroundColor = .systemYellow
        nickNameUpdateButton.layer.cornerRadius = 10
        nickNameUpdateButton.addTarget(self, action: #selector(updateNickName), for: .touchUpInside)

        let vstack = UIStackView(arrangedSubviews: [nickNameTextField, nickNameUpdateButton])
        vstack.translatesAutoresizingMaskIntoConstraints = false
        vstack.axis = .vertical
        vstack.spacing = 12
        vstack.alignment = .fill
        vstack.distribution = .fill
        view.addSubview(vstack)

        NSLayoutConstraint.activate([
            nickNameTextField.heightAnchor.constraint(equalToConstant: 48),
            nickNameUpdateButton.heightAnchor.constraint(equalToConstant: 52),

            vstack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func updateNickName() {
        let trimmed = nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let capped = String(trimmed.prefix(maxNicknameLength))
        completionNickName?(capped.isEmpty ? nil : capped)
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

