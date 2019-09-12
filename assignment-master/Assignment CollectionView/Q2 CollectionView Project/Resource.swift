//
//  Resource.swift
//  Q2 CollectionView Project
//
//  Created by Roopesh on 01/09/19.
//  Copyright © 2019 Roopesh. All rights reserved.
//

import UIKit

enum ResourceType: String {
    case video
    case image
    case doc
    case pdf
}

struct Resource {
    let title: String
    let type: ResourceType
    let filename: String
    let `extension`: String
    let thumbnailImage: String
}
