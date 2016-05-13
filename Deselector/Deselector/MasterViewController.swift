//
//  ViewController.swift
//  Deselector
//
//  Created by Zev Eisenberg on 5/10/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

enum SegueType: String {

    case DefaultDeselection
    case NaïveDeselection
    case SmartDeselection

}

final class MasterViewController: UITableViewController {

    private var segueType: SegueType?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let type = segueType else { return }

        switch type {

        // Here are the different behaviors with UITableViewController:

        // ************************************************
        //
        // If you do nothing special in a UITableViewController,
        // you'll get deselection during the dismissal animation,
        // but if you dismiss interactively, you'll get nothing
        // until after you let go and completion the transition.
        //
        // ************************************************
        case .DefaultDeselection:
            // nothing special to do here
            break


        // ************************************************
        //
        // Most apps do this: just deselect everything
        // in viewWillAppear.
        //
        // ************************************************
        case .NaïveDeselection:
            tableView.indexPathsForSelectedRows?.forEach {
                tableView.deselectRowAtIndexPath($0, animated: true)
            }

        // ************************************************
        //
        // This is the case that looks and works the best.
        // Just stick this line in the viewWillAppear method
        // of any view controller that includes
        //
        // ************************************************
        case .SmartDeselection:
            rz_smoothlyDeselectRows(tableView: tableView)
        }

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let type = SegueType(rawValue: segue.identifier!)!

        segueType = type

        if let detailViewController = segue.destinationViewController as? DetailViewController {
            detailViewController.title = segue.identifier
        }
    }

}

final class DetailViewController: UIViewController { }

extension UIViewController {

    func rz_smoothlyDeselectRows(tableView tableView: UITableView?) {

        // Get the initially selected index paths, if any
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []

        // Grab the transition coordinator responsible for the current transition
        if let coordinator = transitionCoordinator() {
            // Animate alongside the master view controller's view
            coordinator.animateAlongsideTransitionInView(parentViewController?.view, animation: { context in
                // Deselect the cells, with animations enabled if this is an animated transition
                selectedIndexPaths.forEach {
                    tableView?.deselectRowAtIndexPath($0, animated: context.isAnimated())
                }
            }, completion: { context in
                // If the transition was cancel, reselect the rows that were selected before,
                // so they are still selected the next time the same animation is triggered
                if context.isCancelled() {
                    selectedIndexPaths.forEach {
                        tableView?.selectRowAtIndexPath($0, animated: false, scrollPosition: .None)
                    }
                }
            })
        }
        else { // If this isn't a transition coordinator, just deselect the rows without animating
            selectedIndexPaths.forEach {
                tableView?.deselectRowAtIndexPath($0, animated: false)
            }
        }
    }

    // Collection view version works the same as for table views
    func rz_smoothlyDeselectItems(collectionView collectionView: UICollectionView?) {
        let selectedIndexPaths = collectionView?.indexPathsForSelectedItems() ?? []

        if let coordinator = transitionCoordinator() {
            coordinator.animateAlongsideTransitionInView(parentViewController?.view, animation: { context in
                selectedIndexPaths.forEach {
                    collectionView?.deselectItemAtIndexPath($0, animated: context.isAnimated())
                }
            }, completion: { context in
                if context.isCancelled() {
                    selectedIndexPaths.forEach {
                        collectionView?.selectItemAtIndexPath($0, animated: false, scrollPosition: .None)
                    }
                }
            })
        }
        else {
            selectedIndexPaths.forEach {
                collectionView?.deselectItemAtIndexPath($0, animated: false)
            }
        }
    }
    
}
