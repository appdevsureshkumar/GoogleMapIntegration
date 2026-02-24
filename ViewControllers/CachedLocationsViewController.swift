import UIKit
import CoreLocation

final class CachedLocationsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var entries: [LocationCache.Entry]
    var onSelectEntry: ((LocationCache.Entry) -> Void)?

    init(entries: [LocationCache.Entry]) {
        self.entries = entries
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(CachedLocationCell.self, forCellReuseIdentifier: CachedLocationCell.reuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CachedLocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CachedLocationCell.reuseIdentifier,
            for: indexPath
        ) as? CachedLocationCell ?? CachedLocationCell(style: .default, reuseIdentifier: CachedLocationCell.reuseIdentifier)
        let entry = entries[indexPath.row]
        cell.configure(address: entry.address, coordinate: entry.coordinate)
        return cell
    }
}

extension CachedLocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        onSelectEntry?(entry)
        navigationController?.popViewController(animated: true)
    }
}

private final class CachedLocationCell: UITableViewCell {
    static let reuseIdentifier = "CachedLocationCell"

    private let addressLabel = UILabel()
    private let coordinateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.textColor = .label
        addressLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addressLabel.numberOfLines = 1

        coordinateLabel.translatesAutoresizingMaskIntoConstraints = false
        coordinateLabel.textColor = .secondaryLabel
        coordinateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        coordinateLabel.numberOfLines = 1

        contentView.addSubview(addressLabel)
        contentView.addSubview(coordinateLabel)

        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            coordinateLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            coordinateLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            coordinateLabel.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor),
            coordinateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(address: String, coordinate: CLLocationCoordinate2D) {
        addressLabel.text = address
        coordinateLabel.text = String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }
}
