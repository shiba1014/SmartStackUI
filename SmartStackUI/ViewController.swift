//
//  ViewController.swift
//  SmartStackUI
//
//  Created by shiba on 2020/11/15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let stackLayout = StackFlowLayout()

    let colors: [UIColor] = [.purple, .systemPink, .orange]

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Appearance
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "StackCell", bundle: nil), forCellWithReuseIdentifier: StackCell.reuseIdentifier)

        // MARK: Snapping and Scaling
        collectionView.collectionViewLayout = stackLayout
        collectionView.decelerationRate = .fast
    }
}

// MARK: - Appearance
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StackCell.reuseIdentifier, for: indexPath) as? StackCell else { return .init() }
        cell.backgroundColor = colors[indexPath.row]
        cell.configure("index: \(indexPath.row)")
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
}

// MARK: - Snapping and Scaling
final class StackFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()

        scrollDirection = .vertical
        minimumLineSpacing = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Snapping
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else { return proposedContentOffset }

        let targetRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
        let verticalCenter = proposedContentOffset.y + collectionView.frame.height / 2
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude

        // Retrieve the layout attributes for all of the cells in the target rectangle.
        guard let attributesList = super.layoutAttributesForElements(in: targetRect) else { return proposedContentOffset }
        for attributes in attributesList {
            // Find the nearest attributes to the center of collectionView.
            if abs(attributes.center.y - verticalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = attributes.center.y - verticalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
    }

    // MARK: Scaling
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // To enable a layout update while scrolling
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        guard let collectionView = collectionView,
              let attributesList = super.layoutAttributesForElements(in: rect) else { return nil }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        attributesList.forEach { attributes in
            let distance = visibleRect.midY - attributes.center.y
            let newScale = max(1 - abs(distance) * 0.001, 0.9)

            attributes.transform = .init(scaleX: newScale, y: newScale)
        }

        return attributesList
    }
}
