import Photos
import AssetsLibrary

struct Photos {

  static func fetch(completion: (assets: [PHAsset]) -> Void) {
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = ALAssetsLibrary.authorizationStatus()
    var fetchResult: PHFetchResult?

    guard authorizationStatus == .Authorized else { return }

    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
    }

    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      fetchResult?.enumerateObjectsUsingBlock { object, index, stop in
        if let asset = object as? PHAsset {
          assets.append(asset)
        }
      }

      dispatch_async(dispatch_get_main_queue(), {
        completion(assets: assets)
      })
    }
  }

  static func resolveAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280) ,completion: (image: UIImage?) -> Void) {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()

    imageManager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { image, info in
      if let info = info where info["PHImageFileUTIKey"] == nil {
        dispatch_async(dispatch_get_main_queue(), {
          completion(image: image)
        })
      }
    })
  }

  static func resolveAssets(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()

    var images = [UIImage]()

    requestOptions.synchronous = true

    for asset in assets {
      imageManager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { image, info in
        if let image = image {
          images.append(image)
        }
      })
    }
    
    return images
  }
}
