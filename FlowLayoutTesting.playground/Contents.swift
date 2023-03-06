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

    private let params: GeometricParams

    private let colors: [UIColor] = [
        .black, .blue, .brown,
        .cyan, .green, .orange,
        .red, .purple, .yellow
    ]

    let count: Int

    init(count: Int, using params: GeometricParams) {
        self.count = count
        self.params = params
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier,
                                                            for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.contentView.backgroundColor = colors[Int.random(in: 0..<colors.count)]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellsPerRow)
        let height: CGFloat
        if indexPath.row % 6 < 2 {
            height = 2 / 3
        } else {
            height = 1 / 3
        }
        return CGSize(width: cellWidth, height: cellWidth * height)
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

let size = CGRect(origin: .zero, size: CGSize(width: 400, height: 600))
let params = GeometricParams(cellsPerRow: 2,
                             leftInset: 10,
                             rightInset: 10,
                             cellSpacing: 10)
let layout = UICollectionViewFlowLayout()
// Изменим направление скроллинга с вертикального (по умолчанию) на горизонтальное
layout.scrollDirection = .horizontal
let helper = SupplementaryCollection(count: 31, using: params)
let collection = UICollectionView(frame: size, collectionViewLayout: layout)
collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
collection.backgroundColor = .lightGray
collection.dataSource = helper
collection.delegate = helper

PlaygroundPage.current.liveView = collection
collection.reloadData()
