import * as THREE from 'three'
import './style.css'

import gsap from 'gsap'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'

import { GUI } from 'three/addons/libs/lil-gui.module.min.js'
import Stats from 'three/addons/libs/stats.module.js'

import cubeVertexShader from './shaders/Cube_Vertex.glsl'
import cubeFragmentShader from './shaders/Cube_Fragment.glsl'

const scene = new THREE.Scene()

const stats = new Stats()
document.body.appendChild(stats.dom);

const params = {
  width: window.innerWidth,
  height: window.innerHeight
}

const camera = new THREE.PerspectiveCamera(
  50, 
  params.width / params.height,
  0.01, 
  1000
)
camera.position.set(-2, 2, -2)
scene.add(camera)











const mandel = {
  autoPower: false,
  style: 6,
  detail: 10,
  withMist: true,
  onlyMist: false,
  mistFact: 5,

  innerHex: "#5db6ad",
  outerHex: "#FFFFFF"
}

const size = 5;
const cubeGeo = new THREE.BoxGeometry(size, size, size, 2, 2, 2)
const cubeMat = new THREE.RawShaderMaterial({
  vertexShader: cubeVertexShader,
  fragmentShader: cubeFragmentShader,
  side: THREE.BackSide
})
cubeMat.uniforms.camPos = {value: new THREE.Vector3(camera.position.x, camera.position.y, camera.position.z)}
cubeMat.uniforms.uTime = {value: 0}
cubeMat.uniforms.autoPower = {value: mandel.autoPower}
cubeMat.uniforms.power = {value: mandel.style}
cubeMat.uniforms.detail = {value: mandel.detail}
cubeMat.uniforms.withMist = {value: mandel.withMist}
cubeMat.uniforms.onlyMist = {value: mandel.onlyMist}
cubeMat.uniforms.mistFact = {value: mandel.mistFact}
cubeMat.uniforms.innerCol = {value: new THREE.Color(mandel.innerHex)}
cubeMat.uniforms.outerCol = {value: new THREE.Color(mandel.outerHex )}
const cubeMesh = new THREE.Mesh(cubeGeo, cubeMat)
scene.add(cubeMesh)










const canvas = document.querySelector(".webgl")
const renderer = new THREE.WebGLRenderer({
  antialias: true,
  canvas
})
renderer.setSize(params.width, params.height)
renderer.render(scene, camera)

const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true;
//controls.enableZoom = false;
controls.enablePan = false;

let time = 0;








const gui = new GUI({})
gui.domElement.id = 'gui';

const styleFolder = gui.addFolder("Style")
styleFolder.domElement.id = 'styleGUI';

styleFolder.add(mandel, 'autoPower').name('Animate')
styleFolder.add(mandel, 'style', 2, 16).name('Style')
styleFolder.add(mandel, 'detail', 1, 100).name('Detail')
styleFolder.add(mandel, 'withMist').name('With Mist?')
styleFolder.add(mandel, 'onlyMist').name('Only Mist?')
styleFolder.add(mandel, 'mistFact', 2, 10).name('Mist Factor')

const colorFolder = gui.addFolder("Colors")
colorFolder.domElement.id = 'colorGUI';

colorFolder.addColor(mandel, 'innerHex').onChange((value) => {
  cubeMat.uniforms.innerCol.value = new THREE.Color(value)
}).name("Inner Color")

colorFolder.addColor(mandel, 'outerHex').onChange((value) => {
  cubeMat.uniforms.outerCol.value = new THREE.Color(value)
}).name("Outer Color")









window.addEventListener('resize', () => {

  params.width = window.innerWidth,
  params.height = window.innerHeight,

  camera.aspect = params.width / params.height,
  camera.updateProjectionMatrix(),
  renderer.setSize(params.width, params.height)
})

const update = () => {
  
  time += 0.01

  cubeMat.uniforms.camPos = {value: new THREE.Vector3(camera.position.x, camera.position.y, camera.position.z)}
  cubeMat.uniforms.uTime = {value: time}
  cubeMat.uniforms.autoPower = {value: mandel.autoPower}
  cubeMat.uniforms.power = {value: mandel.style}
  cubeMat.uniforms.detail = {value: mandel.detail}
  cubeMat.uniforms.withMist = {value: mandel.withMist}
  cubeMat.uniforms.onlyMist = {value: mandel.onlyMist}
  cubeMat.uniforms.mistFact = {value: mandel.mistFact}

  renderer.render(scene, camera)
  controls.update()

  //planeMat.uniforms.uTime = {value: time},

  stats.update()

  window.requestAnimationFrame(update)
}
update()

const tl = gsap.timeline({defaults: {duration: 1}})
//tl.fromTo(camera.position, {x: 0, y: 0, z: 0}, {x: -2, y: 2, z: -2})
tl.fromTo(cubeMesh.scale, {x: 0, y: 0, z: 0}, {x: 1, y: 1, z: 1})