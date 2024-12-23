use std::collections::{HashMap, HashSet};
use std::io::Read;

fn main() -> Result<(), Box<dyn std::error::Error>> {
  let mut s = String::new();
  std::io::stdin().read_to_string(&mut s)?;

  let pairs = s
    .lines()
    .map(|x| {
      let b = x.as_bytes();
      ([b[0], b[1]], [b[3], b[4]])
    })
    .collect::<Vec<_>>();

  let mut graph = HashMap::new();
  for (a, b) in pairs {
    if a < b {
      graph.entry(a).or_insert(vec![]).push(b);
      graph.entry(b).or_insert(vec![]);
    } else {
      graph.entry(a).or_insert(vec![]);
      graph.entry(b).or_insert(vec![]).push(a);
    }
  }
  for (k, v) in &mut graph {
    v.sort();
  }
  let mut vertices = graph.keys().cloned().collect::<Vec<_>>();
  vertices.sort();

  let mut res = 0;
  for a in &vertices {
    for b in &graph[a] {
      for c in &graph[b] {
        if graph[a].contains(c) {
          if a[0] == b't' || b[0] == b't' || c[0] == b't' {
            res += 1;
          }
        }
      }
    }
  }

  println!("Part 1: {}", res);

  fn grow(
    vertices: &[[u8; 2]],
    graph: &HashMap<[u8; 2], Vec<[u8; 2]>>,
    nodes: HashSet<[u8; 2]>,
    n: usize,
  ) -> HashSet<[u8; 2]> {
    let mut biggest = nodes.clone();
    for (i, v) in vertices[n..].iter().enumerate() {
      if nodes.iter().all(|x| graph[x].contains(v)) {
        let mut nodes = nodes.clone();
        nodes.insert(*v);
        let cand = grow(vertices, graph, nodes, n + i + 1);
        if cand.len() > biggest.len() {
          biggest = cand;
        }
      }
    }
    biggest
  }

  fn find_clique(graph: &HashMap<[u8; 2], Vec<[u8; 2]>>) -> HashSet<[u8; 2]> {
    graph.iter().map(|(v, neighbors)| {
      let mut nodes = HashSet::new();
      nodes.insert(*v);
      grow(&neighbors, graph, nodes, 0)
    }).max_by_key(|x| x.len()).unwrap()
  }

  let clique = find_clique(&graph);
  let mut verts = clique.iter().map(|x| String::from_utf8_lossy(x)).collect::<Vec<_>>();
  verts.sort();

  println!("Part 2: {}", verts.join(","));

  Ok(())
}
