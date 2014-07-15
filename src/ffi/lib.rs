// Copyright 2014 The Servo Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#![crate_type = "lib"]
#![crate_name = "ffi"]
#![license = "ASL2/MIT"]
#![comment = "Generated bindings to the components of the EFL required by \
              efl-rs."]

#![allow(dead_code)]
#![allow(uppercase_variables)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case_functions)]

#![feature(phase)]

#[phase(plugin)]
extern crate bindgen;
extern crate libc;

bindgen!("./extern/efl.h", link="ecore", link="ecore_evas", link="evas", link="eina")
