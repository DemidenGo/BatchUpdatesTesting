import UIKit
import PlaygroundSupport

extension UIView {
    static var identifier: String {
        String(describing: self)
    }
}

final class ColorCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SupplementaryCollection: NSObject, UICollectionViewDataSource {

    private let collection: UICollectionView
    private let params: GeometricParams

    private var colors = [UIColor]()

    init(using params: GeometricParams, collection: UICollectionView) {
        self.params = params
        self.collection = collection
        super.init()
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collection.dataSource = self
        collection.delegate = self
        collection.reloadData()
    }

    func add(colors values: [UIColor]) {
        guard !values.isEmpty else { return }
        let count = colors.count
        colors += values
        collection.performBatchUpdates {
            let indices = (count..<colors.count).map { IndexPath(row: $0, section: 0) }
            collection.insertItems(at: indices)
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier,
                                                            for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.contentView.backgroundColor = colors[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellsPerRow)
        return CGSize(width: cellWidth, height: cellWidth * 2 / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }

    // отвечает за вертикальные отступы
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    // отвечает за горизонтальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colors[indexPath.row]
        var deletedItemsIndicies = [Int]()
        colors.enumerated().forEach { index, value in
            if value == selectedColor {
                deletedItemsIndicies.append(index)
            }
        }
        deletedItemsIndicies.reversed().forEach {
            colors.remove(at: $0)
        }
        collectionView.performBatchUpdates {
            let deletedIndexPaths = deletedItemsIndicies.map {
                IndexPath(row: $0, section: 0)
            }
            collectionView.deleteItems(at: deletedIndexPaths)
        }
    }
}

struct GeometricParams {
    let cellsPerRow: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    // Параметр вычисляется уже при создании, что экономит время на вычислениях при отрисовке коллекции
    let paddingWidth: CGFloat

    init(cellsPerRow: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellsPerRow = cellsPerRow
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellsPerRow - 1) * cellSpacing
    }
}

let size = CGRect(origin: .zero, size: CGSize(width: 400, height: 400))
let view = UIView(frame: size)
let params = GeometricParams(cellsPerRow: 3,
                             leftInset: 10,
                             rightInset: 10,
                             cellSpacing: 10)
let layout = UICollectionViewFlowLayout()
let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
collection.translatesAutoresizingMaskIntoConstraints = false
collection.backgroundColor = .white
view.addSubview(collection)

PlaygroundPage.current.liveView = view

let helper = SupplementaryCollection(using: params, collection: collection)
let addButton = UIButton(type: .roundedRect, primaryAction: UIAction(title: "Add color", handler: { [weak helper] _ in
    // Массив доступных цветов
    let colors: [UIColor] = [
        .black, .blue, .brown,
        .cyan, .green, .orange,
        .red, .purple, .yellow
    ]
    // Произвольно выберем два цвета из массива
    let selectedColors = (0..<2).map { _ in
        colors[Int.random(in: 0..<colors.count)]
    }
    // Добавим выбранные цвета в коллекцию
    helper?.add(colors: selectedColors)
}))
addButton.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(addButton)

NSLayoutConstraint.activate([
    collection.topAnchor.constraint(equalTo: view.topAnchor),
    collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    collection.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
    addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    addButton.heightAnchor.constraint(equalToConstant: 30)
])
