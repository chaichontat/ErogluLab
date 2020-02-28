from __future__ import print_function, unicode_literals, absolute_import, division

from csbdeep.utils import axes_check_and_normalize, axes_dict, move_channel_for_backend, backend_channels_last


def load_training_data_direct(X, Y, validation_split=0, axes=None, n_images=None, verbose=False):
    """Load training data from file in ``.npz`` format.

        The data file is expected to have the keys:

        - ``X``    : Array of training input images.
        - ``Y``    : Array of corresponding target images.
        - ``axes`` : Axes of the training images.


        Parameters
        ----------
        file : str
            File name
        validation_split : float
            Fraction of images to use as validation set during training.
        axes: str, optional
            Must be provided in case the loaded data does not contain ``axes`` information.
        n_images : int, optional
            Can be used to limit the number of images loaded from data.
        verbose : bool, optional
            Can be used to display information about the loaded images.

        Returns
        -------
        tuple( tuple(:class:`numpy.ndarray`, :class:`numpy.ndarray`), tuple(:class:`numpy.ndarray`, :class:`numpy.ndarray`), str )
            Returns two tuples (`X_train`, `Y_train`), (`X_val`, `Y_val`) of training and validation sets
            and the axes of the input images.
            The tuple of validation data will be ``None`` if ``validation_split = 0``.

        """

    # f = np.load(file)
    # X, Y = f['X'], f['Y']
    # if axes is None:
    #    axes = f['axes']
    axes = axes_check_and_normalize(axes)

    assert X.shape == Y.shape
    assert len(axes) == X.ndim
    assert 'C' in axes
    if n_images is None:
        n_images = X.shape[0]
    assert X.shape[0] == Y.shape[0]
    assert 0 < n_images <= X.shape[0]
    assert 0 <= validation_split < 1

    X, Y = X[:n_images], Y[:n_images]
    channel = axes_dict(axes)['C']

    if validation_split > 0:
        n_val = int(round(n_images * validation_split))
        n_train = n_images - n_val
        assert 0 < n_val and 0 < n_train
        X_t, Y_t = X[-n_val:], Y[-n_val:]
        X, Y = X[:n_train], Y[:n_train]
        assert X.shape[0] == n_train and X_t.shape[0] == n_val
        X_t = move_channel_for_backend(X_t, channel=channel)
        Y_t = move_channel_for_backend(Y_t, channel=channel)

    X = move_channel_for_backend(X, channel=channel)
    Y = move_channel_for_backend(Y, channel=channel)

    axes = axes.replace('C', '')  # remove channel
    if backend_channels_last():
        axes = axes + 'C'
    else:
        axes = axes[:1] + 'C' + axes[1:]

    data_val = (X_t, Y_t) if validation_split > 0 else None

    if verbose:
        ax = axes_dict(axes)
        n_train, n_val = len(X), len(X_t) if validation_split > 0 else 0
        image_size = tuple(X.shape[ax[a]] for a in 'TZYX' if a in axes)
        n_dim = len(image_size)
        n_channel_in, n_channel_out = X.shape[ax['C']], Y.shape[ax['C']]

        print('number of training images:\t', n_train)
        print('number of validation images:\t', n_val)
        print('image size (%dD):\t\t' % n_dim, image_size)
        print('axes:\t\t\t\t', axes)
        print('channels in / out:\t\t', n_channel_in, '/', n_channel_out)

    return (X, Y), data_val, axes