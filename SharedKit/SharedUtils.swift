//
//  Utils.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


//////////////////////////
////// Thread Utils //////
//////////////////////////

public func dispatch_async_safely_to_main_queue(block: @escaping ()->())
{
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}

public func dispatch_async_to_background_queue(block: @escaping () -> ())
{
    dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), block)
}

public func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->())
{
    if queue === DispatchQueue.main, Thread.isMainThread
    {
        block()
    }
    else
    {
        queue.async {
            block()
        }
    }
}

public func dispatch_delay_in_main_queue(delay: TimeInterval, block: @escaping ()->())
{
    if Thread.isMainThread
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: block)
    }
}

