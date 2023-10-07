type t = LastUsed | UsageCount | Name

let fromString = sort => {
  switch sort {
  | "last-used" => Some(LastUsed)
  | "name" => Some(Name)
  | "usage-count" => Some(UsageCount)
  | _ => None
  }
}
