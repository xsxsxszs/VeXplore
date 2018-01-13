//
//  AvatarImageView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class AvatarImageView: UIImageView
{
    private var imageDownloadId: ImageDownloadId?
    
    func avatarImage(withURL url: URL)
    {
        setImage(withURL: url, placeholderImage: R.Image.AvatarPlaceholder, imageProcessing: { (image) -> UIImage in
            return image.roundCornerImage()
        })
    }
    
    func cancelImageDownloadTaskIfNeed()
    {
        guard let imageDownloadId = imageDownloadId else {
            return
        }
        ImageDownloader.default.cancelImageDownloadTask(for: imageDownloadId)
        self.imageDownloadId = nil
    }
    
    private func setImage(withURL url: URL, placeholderImage: UIImage?, imageProcessing:((_ image: UIImage) -> UIImage)?)
    {
        image = placeholderImage
        ImageCache.default.retrieveImage(forKey: url.cacheKey) { image in
            if image != nil
            {
                dispatch_async_safely_to_main_queue {
                    self.image = image
                }
            }
            else
            {
                self.cancelImageDownloadTaskIfNeed()
                self.imageDownloadId = ImageDownloader.default.downloadImage(with: url, completionHandler: { (image, originalData, error) in
                    if let image = image, let roundedImage = imageProcessing?(image)
                    {
                        // cache image
                        ImageCache.default.cache(image: roundedImage, forKey: url.cacheKey)
                        dispatch_async_safely_to_main_queue {
                            self.image = roundedImage
                        }
                    }
                })
            }
        }
    }
    
}
