from setuptools import find_packages, setup

package_name = 'falcon1_perception'

setup(
    name=package_name,
    version='0.1.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Nerd Labs',
    maintainer_email='team@nerdlabs.com',
    description='FALCON-1 perception: ToolDetector (Tool x3) + Human Tracker',
    license='MIT',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [],
    },
)
