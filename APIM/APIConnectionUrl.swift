//
//  APIConnectionUrl.swift
//  Umoe
//
//  Created by Manjit on 12/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//

struct APIConnectionUrl {
    // get default url

    static let initialLoadUrl: String = DefaultApiUrl + "restaurants/initial_load"
    static let searchStoreListUrl = DefaultApiUrl + "restaurants/search"
    static let restaurantMenuDetailUrl = DefaultApiUrl + "restaurants/%@"
    
    // draft related urls
    static let draftOrderUrl = DefaultApiUrl + "draft_orders"
    static let addItemToDraftUrl = draftOrderUrl + "/%@/items"
    static let updateDraftItemUrl = draftOrderUrl + "/%@/items/%@"
    static let updateDraftUrl = draftOrderUrl + "/%@"
    static let completeDraftOrderUrl = draftOrderUrl + "/%@" + "/complete"
    
    //user api urls
    static let userBaseUrl = DefaultApiUrl + "users/"
    static let userLoginUrl = userBaseUrl+"login"

}
