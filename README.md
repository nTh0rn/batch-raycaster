


<a id="readme-top"></a>
<div align="center">
<h1 align="center">Batch Raycaster</h1>

  <p align="center">
    A Wolfenstein3D-like raycaster made in Windows Batch.
  </p>

  <p align="center">
<img src="https://nthorn.com/images/batch_raycaster/batch_raycaster_walking.gif" width="500">
<h6>*not real-time frame generation</h6>
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
    <li>
    <a href="#usage">Usage</a>
    <ul>
        <li><a href="#troubleshooting">Troubleshooting</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT -->
## About

This is an old-school DDA raycaster made in Windows Batch. This project is notable for its functionality despite Batch's lack of floating point arithmetic or built-in trigonometric functions.

Per Batch's limitations, frames take roughly 1.5 seconds to generate and movement is done via console-inputs (`set /p`).

[Read an in-depth analysis of this project here](https://nthorn.com/articles/batch_raycaster).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INSTALLATION -->
## Getting started

### Prerequisites

Designed exclusively for Windows. Functionality within Linux/macOS virtual environments may vary (e.g. [wine](https://www.winehq.org/)).

### Installation

1. Clone/download the repo
   ```sh
   git clone https://github.com/nTh0rn/batch-raycaster.git
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE -->
## Usage
1. Modify [`map.txt`](map.txt) to contain the map of your choice. Use `.` to denote empty space, `@` to denote the player's position, and use any other character to denote walls _except for_ `'` or `#`, which are reserved for internal use.
2. Double click [`raycaster.bat`](raycaster.bat) or execute from Command Prompt.
3. Movement/aiming commands relative to the top-down map\
   3.1 `w`=north, `a`=west, `s`=south, `d`=east\
   3.2 `z #`=aim left, `x #`=aim right, where `#` is the number of degrees to turn.

<b>NOTE:</b>
Run [`raycaster-optimized.bat`](raycaster-optimized.bat) instead of [`raycaster.bat`](raycaster.bat) for greatly increased performance at the cost of unreadable code.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Troubleshooting

1. If your Windows' language isn't set to English, you may encounter issues due to Unicode printing. In which case, try out the versions within [/no-unicode/](./no-unicode/).

2. Set `debug_show_wall_type=true` to show the walls' char from [map.txt](map.txt) both within the FOV and within the mini-map for debugging purposes.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Nikolas Thornton - [nthorn.com](https://nthorn.com) - contact@nthorn.com

<p align="right">(<a href="#readme-top">back to top</a>)</p>

