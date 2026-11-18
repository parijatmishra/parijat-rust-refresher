fn main() {
    let owned = String::from("rust");
    let view = &owned;
    println!("{view}");
    assert_eq!(owned, "rust");
}
