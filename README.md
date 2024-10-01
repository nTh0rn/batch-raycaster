


<a id="readme-top"></a>
<div align="center">
<h1 align="center">Batch Raycaster</h1>

  <p align="center">
    A Wolfenstein3D-like raycaster made in Windows Batch.
  </p>

  <p align="center">
<img src="https://nthorn.com/images/batch_raycaster/batch_raycaster_walking.gif" width="500">
</p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about">About</a>
    </li>
    <li>
      <a href="#getting-started">Getting started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT -->
## About
Read an in-depth analysis of this project [here](https://nthorn.com/articles/batch-raycaster).

This is an old-school DDA raycaster made in Windows Batch. This project is notable for its functionality despite Batch's lack of floating point arithmetic or built-in trigonometric functions.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INSTALLATION -->
## Getting started

### Prerequisites

Designed exclusively for Windows. Functionality within Linux/macOS virtual environments may vary.

### Installation

1. Clone/download the repo
   ```sh
   git clone https://github.com/nTh0rn/batch-raycaster.git
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE -->
## Usage
1. Modify [`map.txt`](https://github.com/nTh0rn/batch-raycaster/blob/master/map.txt) to contain the map of your choice. By default, the '`·`' character denotes empty cells.
2. Double click [`raycaster.bat`](https://github.com/nTh0rn/batch-raycaster/blob/master/raycaster.bat) or execute from Command Prompt.
3. Movement/aiming commands\
   3.1 `w`=north, `a`=west, `s`=south, `d`=east\
   3.2 `z #`=aim left, `x #`=aim right, where `#` is the number of degrees to turn.

<b>NOTE:</b>
Run [`optimized/raycaster_optimized.bat`](https://github.com/nTh0rn/batch-raycaster/blob/master/optimized/raycaster.bat) instead of [`raycaster.bat`](https://github.com/nTh0rn/batch-raycaster/blob/master/raycaster.bat) for greatly increased performance at the cost of unreadable code.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Nikolas Thornton - [nthorn.com](https://nthorn.com) - contact@nthorn.com

<p align="right">(<a href="#readme-top">back to top</a>)</p>

