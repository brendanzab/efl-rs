// Copyright 2014 The Servo Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

///! Running on osx: `ECORE_EVAS_ENGINE="opengl_cocoa" ./simple`

extern crate efl;

struct OnKeyDown;

impl efl::KeyDownCallback for OnKeyDown {
    fn call(&self, window: &efl::Window, info: &efl::KeyDown) {
        println!("KEY: {}", info.keyname());
        window.set_title(format!("key pressed(time: {})", info.timestamp()).as_slice());
    }
}

struct OnDestroy;

impl efl::EventCallback for OnDestroy {
    fn call(&self, window: &efl::Window) {
        window.get_context().main_loop_quit();
    }
}

struct OnResize;

impl efl::EventCallback for OnResize {
    fn call(&self, _: &efl::Window) {
        println!("resized");
    }
}

fn main() {
    let evas = efl::init().unwrap();
    for name in evas.get_engine_list().iter() {
        println!("{}", name);
    }
    let mut window = evas.new_window(0, 0, 800, 600).create().unwrap();
    window.set_title("hurro.");
    println!("Window title: \"{}\"", window.get_title());
    window.set_key_down_callback(box OnKeyDown);
    window.set_destroy_callback(box OnDestroy);
    window.set_resize_callback(box OnResize);
    window.show();

    evas.main_loop_begin();
}
